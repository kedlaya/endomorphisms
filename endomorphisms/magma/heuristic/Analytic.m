/***
 *  Finding an approximate basis for the geometric endomorphism ring
 *
 *  Copyright (C) 2016-2017
 *            Edgar Costa      (edgarcosta@math.dartmouth.edu)
 *            Davide Lombardo  (davide.lombardo@math.u-psud.fr)
 *            Jeroen Sijsling  (jeroen.sijsling@uni-ulm.de)
 *
 *  See LICENSE.txt for license details.
 */


intrinsic ComplexStructure(P::ModMatFldElt) -> AlgMatElt
{Returns the complex structure that corresponds to the period matrix P. It is
the RR-linear transformation on homology that corresponds to multiplication
with i.}

CC := BaseRing(P); RR := RealField(CC);
PSplit := VerticalSplitMatrix(P); iPSplit := VerticalSplitMatrix(CC.1 * P);
return NumericalRightSolve(PSplit, iPSplit);

end intrinsic;


intrinsic RationalHomomorphismEquations(JP::., JQ::.) -> .
{Given two complex structures JP and JQ, returns the equations on homology
satisfied by a homomorphism between the two corresponding abelian varieties.}

/* Basic invariants */
RR := BaseRing(JP);
gP := #Rows(JP) div 2; gQ := #Rows(JQ) div 2;
n := 4 * gP * gQ;
/* Building a formal matrix corresponding to all possible integral
 * transformations of the lattice */
R := PolynomialRing(RR, n);
vars := GeneratorsSequence(R);
M := Matrix(R, 2 * gQ, 2 * gP, vars);
/* Condition that integral transformation preserve the complex structure */
Comm := Eltseq(M * ChangeRing(JP, R) - ChangeRing(JQ, R) * M);
/* Splitting previous linear equations by formal variable */
return Matrix(RR, [ [MonomialCoefficient(c, var) : c in Comm] : var in vars ]);

end intrinsic;


intrinsic TangentRepresentation(R::., P::ModMatFldElt, Q::ModMatFldElt) -> .
{Given a homology representation R of a homomorphism and two period matrices P
and Q, returns an analytic representation A of that same homomorphism, so that
A P = Q R.}

CC := BaseRing(P);
P0, s0 := InvertibleSubmatrix(P : IsPeriodMatrix := true);
QR := Q * ChangeRing(R, CC);
QR0 := Submatrix(QR, [ 1..#Rows(QR) ], s0);
A := NumericalLeftSolve(P0, QR0);
if Maximum([ Abs(c) : c in Eltseq(A*P - Q*ChangeRing(R, CC)) ]) gt CC`epscomp then
    error "Error in determining tangent representation";
end if;
return A;

end intrinsic;


intrinsic TangentRepresentation(R::., P::ModMatFldElt) -> .
{Given a homology representation R of an endomorphism and a period matrix P,
returns an analytic representation of that same endomorphism, so that A P = Q
R.}

return TangentRepresentation(R, P, P);

end intrinsic;


intrinsic HomologyRepresentation(A::., P::ModMatFldElt, Q::ModMatFldElt) -> .
{Given a complex tangent representation A of a homomorphism and two period
matrices P and Q, returns a homology representation R of that same
homomorphism, so that A P = Q R.}

CC := BaseRing(P);
SplitAP := VerticalSplitMatrix(A * P);
SplitQ := VerticalSplitMatrix(Q);
RRR := NumericalRightSolve(SplitQ, SplitAP);
R := Matrix(Integers(), [ [ Round(cRR) : cRR in Eltseq(row) ] : row in Rows(RRR) ]);
if Maximum([ Abs(c) : c in Eltseq(A*P - Q*ChangeRing(R, CC)) ]) gt CC`epscomp then
    error "Error in determining homology representation";
end if;
return R;

end intrinsic;


intrinsic HomologyRepresentation(A::., P::ModMatFldElt) -> .
{Given a complex tangent representation A of an endomorphism and a period
matrix P, returns a homology representation R of that same endomorphism, so
that A P = P R.}

return HomologyRepresentation(A, P, P);

end intrinsic;


intrinsic GeometricHomomorphismRepresentationCC(P::ModMatFldElt, Q::ModMatFldElt) -> SeqEnum
{Given period matrices P and Q, this function determines a ZZ-basis of
homomorphisms between the corresponding abelian varieties. These are returned
as pairs of a complex tangent representation A and a homology representation R
for which A P = Q R.}

/* Basic invariants */
gP := #Rows(P); gQ := #Rows(Q);
JP := ComplexStructure(P); JQ := ComplexStructure(Q);

/* Determination of approximate endomorphisms by LLL */
M := RationalHomomorphismEquations(JP, JQ);
Ker, test := IntegralLeftKernel(M : EndoRep := true);
if not test then
    return [ ];
end if;

/* Deciding which rows to keep */
CC := BaseRing(P); RR := BaseRing(JP); gens := [ ];
for r in Rows(Ker) do
    R := Matrix(Rationals(), 2*gQ, 2*gP, Eltseq(r));
    /* Culling the correct transformations from holomorphy condition */
    Comm := ChangeRing(R, RR) * JP - JQ * ChangeRing(R, RR);
    if &and([ (RR ! Abs(c)) lt RR`epscomp : c in Eltseq(Comm) ]) then
        A := TangentRepresentation(R, P, Q);
        if Maximum([ Abs(c) : c in Eltseq(A*P - Q*ChangeRing(R, CC)) ]) gt CC`epscomp then
            error "Error in determining homomorphism representations";
        end if;
        Append(~gens, [* A, R *]);
    end if;
end for;
return gens;

end intrinsic;


intrinsic GeometricEndomorphismRepresentationCC(P::ModMatFldElt) -> .
{Given a period matrix P, this function determines a ZZ-basis of endomorphisms
of the corresponding abelian variety. These are returned as pairs of a complex
tangent representation A and a homology representation R for which A P = P R.}

return GeometricHomomorphismRepresentationCC(P, P);

end intrinsic;


intrinsic GeometricHomomorphismRepresentation(P::ModMatFldElt, Q::ModMatFldElt, F::Fld : UpperBound := Infinity()) -> SeqEnum
{Given period matrices P and Q, as well as a field F, this function determines
a ZZ-basis of homomorphisms between the corresponding abelian varieties. These
are returned as triples of an algebraized tangent representation A, a homology
representation R and a complex tangent representation ACC. We have ACC P = Q R,
and via the infinite place of F the matrix A is mapped to ACC.}

/* Determine matrices over CC */
gensPart := GeometricHomomorphismRepresentationCC(P, Q);
/* Determine minimal polynomials needed */
gensPol, test := RelativeMinimalPolynomialsMatrices(gensPart, F : UpperBound := UpperBound);
if not test then
    error "No suitable minimal polynomial found";
end if;

/* Create field, using known maximum bounds */
g := #Rows(P);
if g eq 1 then
    Bound := 2;
elif g eq 2 then
    Bound := 48;
else
    Bound := Infinity();
end if;
L := RelativeSplittingFieldExtra(&cat[ Eltseq(gen) : gen in gensPol] : Bound := Bound);

gens := [ ];
/* Algebraize over it */
for i := 1 to #gensPart do
    genApp, R := Explode(gensPart[i]);
    A, test := AlgebraizeMatrixInRelativeField(genApp, L : minpolmat := gensPol[i]);
    if not test then
        error "No suitable algebraic element found";
    end if;
    Append(~gens, [* A, R *]);
end for;
return gens;

end intrinsic;


intrinsic GeometricEndomorphismRepresentation(P::ModMatFldElt, F::Fld : UpperBound := Infinity()) -> SeqEnum
{Given a period matrix P and a field F, this function determines a ZZ-basis of
endomorphisms of the corresponding abelian variety. These are returned as
triples of an algebraized tangent representation A, a homology representation R
and a complex tangent representation ACC. We have ACC P = P R, and via the
infinite place of F the matrix A is mapped to ACC.}

return GeometricHomomorphismRepresentation(P, P, F : UpperBound := UpperBound);

end intrinsic;


/* Allow specification of field: */
intrinsic GeometricEndomorphismRepresentationOverField(gensPart::SeqEnum, L::Fld) -> .
{Given the output of GeometricEndomorphismRepresentationCC and a field L
with an infinite places, writes the tangent representation of the former as
matrices over the latter. Use when delegating to Sage.}

gens := [ ];
for gen in gensPart do
    genApp, R := Explode(gen);
    A, test := AlgebraizeMatrixInRelativeField(genApp, L);
    if not test then
        error "No suitable algebraic element found";
    end if;
    Append(~gens, [* A, R *]);
end for;
return gens;

end intrinsic;
