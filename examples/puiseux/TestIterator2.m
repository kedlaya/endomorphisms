import "../../endomorphisms/magma/puiseux/Initialize.m": InitializeCurve;
import "../../endomorphisms/magma/puiseux/Branches.m": DevelopPoint, InitializeLift, CreateLiftIterator;

prec := 1000;
F := RationalsExtra(prec);
R<x> := PolynomialRing(F);
D := [-5..5];

repeat
    f := x^8 + &+[ Random(D)*x^i : i in [0..7] ];
    f := f - Evaluate(f, 0) + 1;
    X := HyperellipticCurve(f, 0);
    P0 := X ! [0, 1];
until not IsWeierstrassPlace(Place(P0));
print f;
time InitializeCurve(X, P0 : NonWP := true);

repeat
    g := x^8 + &+[ Random(D)*x^i : i in [0..7] ];
    g := g - Evaluate(g, 0) + 1;
    Y := HyperellipticCurve(g, 0);
    Q0 := Y ! [0, 1];
until not IsWeierstrassPlace(Place(Q0));
print g;
time InitializeCurve(Y, Q0 : NonWP := true);

M := Matrix(F, 3, 3, [ Random(D) : i in [1..9] ]);
print "Initializing...";
Iterator := InitializedIterator(X, Y, M, Y`g + 7);
print "done.";

/* Further iteration seems perfect now, no exceptions found yet */
while true do
    IteratorNew := IterateIterator(Iterator);
    QsNew := IteratorNew[2]; Qs := Iterator[2];
    print QsNew[3][2] - Qs[3][2];
    Iterator := IteratorNew;
end while;
