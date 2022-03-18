#!/bin/sh



# //  compile circuit
# // circom merkle.circom --r1cs --wasm --sym --c

# // ptau
# // snarkjs powersoftau new bn128 15 pot12_0000.ptau -v
# // snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v


# // phase2
# // snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
# // snarkjs groth16 setup merkle.r1cs pot12_final.ptau merkle_0000.zkey
# // snarkjs zkey contribute merkle_0000.zkey merkle_0001.zkey --name="1st Contributor Name" -v
# // snarkjs zkey export verificationkey merkle_0001.zkey verification_key.json


# // generate proof
# // snarkjs groth16 prove merkle_0001.zkey witness.wtns proof.json public.json

# // verify proof
# // snarkjs groth16 verify verification_key.json public.json proof.json


compile_circuit() {
    echo "\e[92mwill compile the circuit: \e[96m/$@"
    circom $@.circom --r1cs --wasm --sym --c
    echo "\e[95m=======Creating input.json file in $@_js folder======"
    echo "{}" > $@_js/input.json
    echo "\e[33mSuccess. Now update the input.json file inside $@_js folder."
    echo "\e[33mOnce updated, run the generateAndVerifyProof command with the power of tau(int) and circuit filename(without extension) as a varible."
    return
}

# Param is the file name here
generate_witness() {
    echo "\e[92mGenerating witness for circuit: $@"
    node $@_js/generate_witness.js $@_js/$@.wasm $@_js/input.json $@_js/witness.wtns
}

# Here the param is variable power of tau
setup_ptau() {
    echo "\e[92msetting up power of tau for: \e[96m$@"

    echo "\e[92mRunning:  snarkjs powersoftau new bn128 $@ pot12_0000.ptau -v"
    snarkjs powersoftau new bn128 $@ pot12_0000.ptau -v

    echo "\e[92m========================================================================="


    echo "\e[92mRunning: snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name='First contribution' -v "
    snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
    echo "\e[92m========================================================================="
    echo "\e[92mPower of tau setup complete"
}

# Variable is ciruict file's name without the extension
start_phase2() {
    echo "\e[92mStarting Phase 2"
    echo "\e[92mRunning:  snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v"
    snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
    echo "\e[92m========================================================================="

    echo "\e[92mRunning:  snarkjs groth16 setup $@.r1cs pot12_final.ptau $@_0000.zkey"
    snarkjs groth16 setup "$@.r1cs" pot12_final.ptau "$@_0000.zkey"
    echo "\e[92m========================================================================="

    echo "\e[92mRunning:  snarkjs zkey contribute $@_0000.zkey $@_0001.zkey --name='1st Contributor Name' -v"
    snarkjs zkey contribute $@_0000.zkey $@_0001.zkey --name="1st Contributor Name" -v
    echo "\e[92m========================================================================="
    
    echo "\e[92mRunning::  snarkjs zkey export verificationkey $@_0001.zkey verification_key.json"
    snarkjs zkey export verificationkey $@_0001.zkey verification_key.json
    echo "\e[92m========================================================================="
    echo "\e[92mPhase 2 completed"
}

# Variable is ciruict file's name without the extension
generate_proof() {
    echo "\e[92mGenerating Proof"
    echo "\e[92mRunning::  snarkjs groth16 prove $@_0001.zkey $@_js/witness.wtns proof.json public.json"
    snarkjs groth16 prove $@_0001.zkey $@_js/witness.wtns proof.json public.json
    echo "\e[92m========================================================================="
}

verify_proof() {
    echo "\e[92mVerifying Proof"
    echo "\e[92mRunning::  snarkjs groth16 verify verification_key.json public.json proof.json"
    snarkjs groth16 verify verification_key.json public.json proof.json
    echo "\e[35m========================================================================="
}

# TODO: add a function for generating the smart contract as well.

# Variables are power of tau and file name in this order.
generateAndVerifyProof() {
    local powerOfTau=$1
    local fileName=$2
    generate_witness $fileName
    setup_ptau $powerOfTau
    start_phase2 $fileName
    generate_proof $fileName
    verify_proof
}

