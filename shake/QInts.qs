
/// # Summary
/// Helper functions for operation on 64-qbit values
namespace keccak {

    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;

    // In most cases 1 QInt = 64 Qubits
    newtype QInt = Qubit[];

    /// # Summary
    /// Divides qbits into 64 qbit blocks.
    /// # Input
    /// ## bits
    /// The qbits to divide into blocks
    /// # Output
    /// The QInts containing 64 qubits each in the same order.
    function divideIntoQInts(bits : Qubit[]) : QInt[] {
        let length = Length(bits);
        Fact(length % 64 == 0, $"Could not divide Qubit Array of length {length} into QInts, because they have the wrong length.");
        
        let qIntAmount = length / 64;

        mutable registers = new QInt[qIntAmount];
        if (qIntAmount > 0) {
            for (i in 0 .. qIntAmount - 1) {
                set registers w/= i <- QInt(bits[i * 64 .. (i + 1) * 64 - 1]);
            }
        }

        return registers;
    }

    // function mergeFromQInts(ints : QInt[]) : Qubit[] {
    //     mutable ret = new Qubit[0];
    //     for (i in ints) {
    //         set ret = ret + i!;
    //     }
    //     return ret;
    // }

    /// # Summary
    /// Takes the QInt and returns a new QInt with the qbits rotated to the right by the specified amount.
    /// # Input
    /// ## bits
    /// The QInt to rotate the bits in.
    /// ## amount
    /// The amount by which each bit is rotated to the right.
    /// # Output
    /// The QInt containing the original qbits in rotated order.
    function getRightRotated(bits : QInt, amount : Int) : QInt {
        let actualAmount = (amount % 64 + 64) % 64;
        return QInt(bits![actualAmount .. 63] + bits![0 .. actualAmount - 1]);
    }

    /// # Summary
    /// Same as getRightRotated, but as a rotation to the left.
    function getLeftRotated(bits : QInt, amount : Int) : QInt {
        return getRightRotated(bits, -amount);
    }

    /// # Summary
    /// XORS the control Registers onto the target
    /// # Input
    /// ## controlRegisters
    /// The QInts to compute the XOR of
    /// ## target
    /// The target for the XOR operation
    operation XORInt(controlRegisters : QInt[], target : QInt) : Unit is Adj + Ctl {
        for (control in controlRegisters) {
            for (i in 0 .. 63) {
                CNOT(control![i], target![i]);
            }
        }
    }
}