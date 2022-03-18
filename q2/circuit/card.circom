include "../../node_modules/circomlib/circuits/mimcsponge.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";

template Main() {
    signal input card1;
    signal input suite1;
    signal input card2;
    signal input suite2;
    signal input salt;

    signal output card1Hash;
    signal output card2Hash;
    signal output saltSuiteHash;

    // check for if suite is equal
    signal isSuiteEqual;
    component suiteEqual = IsEqual();
    suiteEqual.in[0] <== suite1;
    suiteEqual.in[1] <== suite2;
    isSuiteEqual <== suiteEqual.out;

    isSuiteEqual === 1;

    // hash the salt & suite
    signal hashSaltSuite1;
    signal hashSaltSuite2;
    component mimc1 = MiMCSponge(2, 220, 1);
    component mimc2 = MiMCSponge(2, 220, 1);

    mimc1.ins[0] <== salt;
    mimc1.ins[1] <== suite1;
    mimc1.k <== 0;

    mimc2.ins[0] <== salt;
    mimc2.ins[1] <== suite2;
    mimc2.k <== 0;

    hashSaltSuite1 <== mimc1.outs[0];
    hashSaltSuite2 <== mimc2.outs[0];
    
    // now hash the card number with the salt + suite hashes.
    component mimcHash1 = MiMCSponge(2, 220, 1);
    component mimcHash2 = MiMCSponge(2, 220, 1);

    mimcHash1.ins[0] <== hashSaltSuite1;
    mimcHash1.ins[1] <== card1;
    mimcHash1.k <== 0;

    mimcHash2.ins[0] <== hashSaltSuite2;
    mimcHash2.ins[1] <== card2;
    mimcHash2.k <== 0;

    card1Hash <== mimcHash1.outs[0]; // this is needed to match against hash in contract.
    card2Hash <== mimcHash2.outs[0]; // this is the hash of new card.

    // BONUS Question:
    // we send the hash of salt and suite of the new card
    // verifier contract can create a similar hash(mimc in this example) using the revealed card + hashSaltSuite2
    // this hash should be equal to the card2Hash. 
    // In this way, we are able to prove that, the player indeed picked the Ace card, without revealing the suite to the contract.
    // note: I have used mimc here as hash, but ideally we should sha256 if the hashing is being performed in the contract as well.
    saltSuiteHash <== hashSaltSuite2; 
    
}

component main = Main();