/*
    Prove: I know (x1,y1,x2,y2,p2,r2,distMax) such that:
    - x2^2 + y2^2 <= r^2
    - perlin(x2, y2) = p2
    - (x1-x2)^2 + (y1-y2)^2 <= distMax^2
    - MiMCSponge(x1,y1) = pub1
    - MiMCSponge(x2,y2) = pub2
*/

include "../../node_modules/circomlib/circuits/mimcsponge.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";


template CheckEnergySpent() {
    signal input x1;
    signal input y1;
    signal input x2;
    signal input y2;
    signal input energy;
    signal output out;

    signal x2Sq;
    signal y2Sq;
    signal energySq;
    signal diffX;
    signal diffY;

    diffX <== x1 - x2;
    diffY <== y1 - y2;

    x2Sq <== diffX * diffX;
    y2Sq <== diffY * diffY;

    energySq <== energy * energy;

    component e = LessEqThan(32);
    e.in[0] <== x2Sq + y2Sq;
    e.in[1] <== energySq;
    out <== e.out;
}

template IsPointInTriangle() {
    signal input x1;
    signal input y1;
    signal input x2;
    signal input y2;
    signal input x3;
    signal input y3;
    signal output out;

    signal diffX2X1;
    signal diffY3Y1;
    signal diffY2Y1;
    signal diffX3X1;

    diffX2X1 <== x2 - x1;
    diffY3Y1 <== y3 - y1;
    diffY2Y1 <== y2 - y1;
    diffX3X1 <== x3 - x1;

    signal mul1;
    signal mul2;
    mul1 <== diffX2X1 * diffY3Y1;
    mul2 <== diffY2Y1 * diffX3X1;

    signal areaDiff;
    areaDiff <== mul1 - mul2;

    component e = IsEqual();
    e.in[0] <== areaDiff;
    e.in[1] <== 0;
    signal isAreaZero;
    isAreaZero <== e.out;
    out <== isAreaZero;
}


template Main() {
    signal input x1;
    signal input y1;
    signal input x2;
    signal input y2;
    signal input x3;
    signal input y3;
    signal input energyPerMove;
    signal output out;

    // energy check per move.
    /* check x2^2 + y2^2 < energyPerMove^2 */
    // A -> B
    component energyCheck1 = CheckEnergySpent();
    energyCheck1.x1 <== x1;
    energyCheck1.y1 <== y1;
    energyCheck1.x2 <== x2;
    energyCheck1.y2 <== y2;
    energyCheck1.energy <== energyPerMove;
    energyCheck1.out === 1;

    // B -> C
    component energyCheck2 = CheckEnergySpent();
    energyCheck2.x1 <== x3;
    energyCheck2.y1 <== y3;
    energyCheck2.x2 <== x2;
    energyCheck2.y2 <== y2;
    energyCheck2.energy <== energyPerMove;
    energyCheck2.out === 1;

    // check if the points fall under a triangle.
    component triangleCheck = IsPointInTriangle();
    triangleCheck.x1 <== x1;
    triangleCheck.x2 <== x2;
    triangleCheck.x3 <== x3;
    triangleCheck.y1 <== y1;
    triangleCheck.y2 <== y2;
    triangleCheck.y3 <== y3;
    triangleCheck.out === 0;

}

component main = Main();