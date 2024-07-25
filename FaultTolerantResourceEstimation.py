#!/usr/bin/python3

import math

# problem characteristics
input_length = 128
grover_iterations = math.floor(math.pi / 4 * 2 ** (input_length / 2))

#circuit characteristics for single grover iteration
# shake256, our implementation, 128 bit parameters
# circuit = {
# 	"T" : 1184491 + 1771,
# 	"CNOT" : 5072866 + 2530,
# 	"QUBITCLIFFORD" : 338614 + 1022,
# 	"WIDTH" : 3456,
# 	"T_DEPTH" : 3635 + 1139
# }
# harakaS, our implementation, 128 bit parameters
circuit = {
	"T" : 2438891 + 1771,
	"CNOT" : 5535458 + 2530,
	"QUBITCLIFFORD" : 758282 + 1022,
	"WIDTH" : 1400,
	"T_DEPTH" : 275713 + 1139
}

# shake256, our implementation 256 bit parameters
# circuit = {
# 	"T" : 1186283 + 3563,
# 	"CNOT" : 5076450 + 5090,
# 	"QUBITCLIFFORD" : 339126 + 2046,
# 	"WIDTH" : 3712,
# 	"T_DEPTH" : 4787 + 2291
# }
# harakaS, our implementation 256 bit parameters, left child node known, right child node searched for
#circuit = {
#	"T" : 2440683 + 3563,
#	"CNOT" : 5538274 + 5090,
#	"QUBITCLIFFORD" : 758794 + 2046,
#	"WIDTH" : 1656,
#	"T_DEPTH" : 276865 + 2291
#}


# https://arxiv.org/pdf/1603.09383.pdf Section 7.1 p.14-15 SHA-256
# circuit = {
# 	"T" : 228992 * 2 + 8108 + 8076,
# 	"CNOT" : 8.76e6 * 0.98,
# 	"QUBITCLIFFORD" : 8.76e6 * 0.02,
# 	"WIDTH" : 2402,
# 	"T_DEPTH" : 70400 * 2
# }
#https://arxiv.org/pdf/1603.09383.pdf Section 7.1 p.17 SHA3-256
# circuit = {
# 	"T" : 1014584,
# 	"CNOT" : 6.85e7,
# 	"QUBITCLIFFORD" : 4.30e5,
# 	"WIDTH" : 3200,
# 	"T_DEPTH" : 432 * 2
# }

grover_circuit = {
	"T" : circuit["T"] * grover_iterations,
	"CNOT" : circuit["CNOT"] * grover_iterations,
	"QUBITCLIFFORD" : circuit["QUBITCLIFFORD"] * grover_iterations,
	"WIDTH" : circuit["WIDTH"],
	"T_DEPTH" : circuit["T_DEPTH"] * grover_iterations
}

# probability of physical error
p_in = 1e-4
# error tolerance for correct algorithm
p_out = 1 / grover_circuit["T"]

time_per_cycle = 200e-9

print(f"p_in: {p_in}\np_out: {p_out}\n")

def getDistillationCodeDistance(p_in, p_out, epsilon = 1, p_g = p_in / 10):
	# https://arxiv.org/pdf/1603.09383.pdf Algorithm 4 p.15
	# https://arxiv.org/pdf/1301.7107.pdf section 2 p.4-5
	p = p_out
	i = 0
	ds = []
	while p <= p_in:
		i += 1
		d = 1
		while 192 * d * ((100 * p_g) ** math.floor((d + 1) / 2)) >= epsilon * p / (1 + epsilon):
			d += 1
		p = (p / (35 * (1 + epsilon))) ** (1/3)
		ds += [d]
	return ds

def getCodeDistance(p_in, clifford_gates):
	# https://arxiv.org/pdf/1603.09383.pdf Equation 12 p.16
	d = 1
	# https://arxiv.org/pdf/1603.09383.pdf uses this equation with (d+1)/2
	# https://arxiv.org/pdf/1010.5022.pdf uses this equation with floor((d+1)/2)
	while (p_in / 0.0125) ** math.floor((d + 1) / 2) >= 1 / clifford_gates:
		d += 1
	return d

def getPhysicalQubitsForSurfaceCodeDistance(d):
	# https://arxiv.org/pdf/1603.09383.pdf Section 7.1 p.15
	# https://arxiv.org/pdf/1208.0928.pdf Appendix M p.52
	return 2.5 * 1.25 * d ** 2

def getLogicalQubitsForDistillationLayer(layer):
	# https://arxiv.org/pdf/1208.0928.pdf Appendix M p.52
	return 16 * 15 ** layer

def getSurfaceCodeCyclesForDistillation(d):
	# https://arxiv.org/pdf/1603.09383.pdf Section 7.1 p.15
	return 10 * d

def getQubitsAndCyclesForDistillation(p_in, p_out):
	distances = getDistillationCodeDistance(p_in, p_out)
	cycles = 0
	qubits = 0
	for i in range(0, len(distances)):
		d = distances[i]
		currentCycles = getSurfaceCodeCyclesForDistillation(d)
		currentQubits = getPhysicalQubitsForSurfaceCodeDistance(d) * getLogicalQubitsForDistillationLayer(i)

		# sequential distillation
		cycles += currentCycles
		# reusing qubits
		qubits = max(qubits, currentQubits)
	return cycles, qubits

def getQubitsClifford(p_in, circuit):
	clifford_gates = circuit["QUBITCLIFFORD"] + circuit["CNOT"]
	width = circuit["WIDTH"]
	distance = getCodeDistance(p_in, clifford_gates)
	return width * getPhysicalQubitsForSurfaceCodeDistance(distance)

def getAverageGatePerTDepth(circuit, gate ="T"):
	return circuit[gate] / circuit["T_DEPTH"]

def getMagicStatesPerDistillery(distances):
	# no pipelining
	return 4
	# # https://arxiv.org/pdf/1603.09383.pdf p.16
	# # Why?
	# def getPhysicalQubitsForDistance(index):
	# 	distance = distances[index]
	# 	return getPhysicalQubitsForSurfaceCodeDistance(distance) * getLogicalQubitsForDistillationLayer(index)
	# # is this always the case?
	# ret = math.floor(getPhysicalQubitsForDistance(len(distances) - 1) / getPhysicalQubitsForDistance(len(distances) - 2))
	# assert ret > 0
	# return ret

def getCyclesCliffordPerTLayer(p_in, circuit):
	# https://arxiv.org/pdf/1603.09383.pdf p.16
	amountQubits = circuit["WIDTH"]
	distance = getCodeDistance(p_in, circuit["QUBITCLIFFORD"] + circuit["CNOT"])

	cyclesPerCnot = 2
	cyclesPerSingleQubit = distance # Most SingleQubit gates are Hadamard

	cyclesCnot = cyclesPerCnot * getAverageGatePerTDepth(circuit, "CNOT") / amountQubits
	cyclesSingleQubit = cyclesPerSingleQubit * getAverageGatePerTDepth(circuit, "QUBITCLIFFORD") / amountQubits

	return cyclesCnot + cyclesSingleQubit

def getAmountDistilleries(circuit, codeDistances):
	averageTGatesPerLayer = getAverageGatePerTDepth(circuit)
	distilleriesNeeded = math.ceil(averageTGatesPerLayer / getMagicStatesPerDistillery(codeDistances))
	return distilleriesNeeded

def getTotalAmountOfLogicalQubits(circuit, distillationCodeDistance):
	return circuit["WIDTH"] + getAmountDistilleries(circuit, distillationCodeDistance) * getLogicalQubitsForDistillationLayer(len(distillationCodeDistance) - 1)

def toTwoToThePowerOf(num):
	exponent = math.floor(math.log2(num))
	pre = num / 2 ** exponent
	return f"{pre}*2^{exponent}"

print("Grover circuit:")
for e in grover_circuit:
	print(f"{e}: {grover_circuit[e] * 1.}")
print("\n")

ds = getDistillationCodeDistance(p_in, p_out)
print(f"Distillation distances: {ds}")
cycles, qubits = getQubitsAndCyclesForDistillation(p_in, p_out)
parallel_states = getMagicStatesPerDistillery(ds)
print(f"Distillation takes {cycles} cycles on {qubits} physical qubits producing {parallel_states} distilled states")

codeDistance = getCodeDistance(p_in, grover_circuit["QUBITCLIFFORD"] + grover_circuit["CNOT"])
print(f"Code distance: {codeDistance}")

qubitsClifford = getQubitsClifford(p_in, grover_circuit)
print(f"Physical qubits for Clifford: {qubitsClifford}")

distilleriesNeeded = getAmountDistilleries(grover_circuit, ds)
print(f"Distilleries needed: {distilleriesNeeded}")

print("T-Gates per layer: %s\nCNOT-Gates per layer per qubit: %s\nQUBITCLIFFORD-Gates per layer per gate: %s" % (
	getAverageGatePerTDepth(circuit),
	getAverageGatePerTDepth(circuit, "CNOT") / circuit["WIDTH"],
	getAverageGatePerTDepth(circuit, "QUBITCLIFFORD") / circuit["WIDTH"]
))
cliffordCyclesPerTLayer = getCyclesCliffordPerTLayer(p_in, grover_circuit)
distilleryCyclesPerTLayer = cycles
print(f"Average cycles for Clifford gates per T-Depth: {cliffordCyclesPerTLayer}")
print(f"Total cycles for T gates per T-Depth: {distilleryCyclesPerTLayer * 1.}")
assert distilleryCyclesPerTLayer > cliffordCyclesPerTLayer # What happens if we use more clifford cycles than distillery cycles? do we use less distilleries?
totalCycles = max(cliffordCyclesPerTLayer, distilleryCyclesPerTLayer) * grover_circuit["T_DEPTH"]
print(f"Total cycles: {totalCycles * 1.} = 2^{math.log2(totalCycles)}")
print(f"Total cycles: {toTwoToThePowerOf(totalCycles)}")
print(f"Time: {time_per_cycle * totalCycles}s or {time_per_cycle * totalCycles / 60 / 60 / 24 / 365} years")

totalLogicalQubits = getTotalAmountOfLogicalQubits(grover_circuit, ds)
print(f"Total logical qubits: {totalLogicalQubits}")
print(f"Total physical qubits: {qubits * distilleriesNeeded + qubitsClifford}")
print(f"Cost metric: {totalLogicalQubits * totalCycles * 1.}")
print(f"Cost metric: {toTwoToThePowerOf(totalLogicalQubits * totalCycles)}")
