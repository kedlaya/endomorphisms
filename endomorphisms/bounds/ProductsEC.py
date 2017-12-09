"""
 *  Bound functionality
 *
 *  Copyright (C) 2016-2017
 *            Edgar Costa      (edgarcosta@math.dartmouth.edu)
 *            Davide Lombardo  (davide.lombardo@math.u-psud.fr)
 *            Jeroen Sijsling  (jeroen.sijsling@uni-ulm.de)
 *
 *  See LICENSE.txt for license details.
"""

from sage.all import NumberField

def RankBoundProductEC(LPolys):
    g = 2                           # only for surfaces
    NotSquareCM = IsGeometricallyNotSquareOfCM(LPolys)
    if NotSquareCM == False :
    return 8;

    IsSquare = True

    for p in range (2,maxP):
      if LPolys[p] <> 0 :
        q = LPolys[p]
        q = twistPolynomial(q, 2*extensionBounds[g])

        if(q.is_square() == False) :
            IsSquare = False
        break

    if IsSquare :
        return 4

    FoundDifferentDiscriminants = False
    Initialized = False
    Discriminants = {}

    for p in range (2,maxP):
      if LPolys[p] <> 0 :
        q = LPolys[p]
        q = twistPolynomial(q, 2*extensionBounds[g])
    if(q.is_square() == False) :
            r = q.factor()
        l1 = r[0][0];
        l2 = r[1][0];
        if l1.degree() == 2 and l2.degree() == 2:
            if l1.coefficients(sparse = False)[1] % p <> 0 and l2.coefficients(sparse = False)[2] % p <> 0 :
            K1 = NumberField(l1, 'u1');
            K2 = NumberField(l2, 'u2');
            d1 = K1.discriminant()
            d2 = K2.discriminant()
            if d1 <> d2 :
                FoundDifferentDiscriminants = True
            if not Initialized :
                Initialized = True
                Discriminants = {d1, d2}
            Discriminants = Discriminants.intersection({d1, d2})
            if len(Discriminants) == 0 :
                break;

    if FoundDifferentDiscriminants :
    return 2 + len(Discriminants)
    else :
    if len(Discriminants) == 0 :
        return 2;
    else :
        return 4;
