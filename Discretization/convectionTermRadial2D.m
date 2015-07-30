function [M, Mx, My] = convectionTermRadial2D(u)
% This function uses the central difference scheme to discretize a 2D
% convection term in the form \grad (u \phi) where u is a face vactor
% It also returns the x and y parts of the matrix of coefficient.
%
% SYNOPSIS:
%   [M, Mx, My] = convectionTermRadial2D(u)
%
% PARAMETERS:
%
%
% RETURNS:
%
%
% EXAMPLE:
%
% SEE ALSO:
%

%{
Copyright (c) 2012, 2013, Ali Akbar Eftekhari
All rights reserved.

Redistribution and use in source and binary forms, with or
without modification, are permitted provided that the following
conditions are met:

    *   Redistributions of source code must retain the above copyright notice,
        this list of conditions and the following disclaimer.
    *   Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials provided
        with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%}

% extract data from the mesh structure
Nr = u.domain.dims(1);
Ntetta = u.domain.dims(2);
G=reshape(1:(Nr+2)*(Ntetta+2), Nr+2, Ntetta+2);
DRe = repmat(u.domain.cellsize.x(3:end), 1, Ntetta);
DRw = repmat(u.domain.cellsize.x(1:end-2), 1, Ntetta);
DRp = repmat(u.domain.cellsize.x(2:end-1), 1, Ntetta);
DTHETAn = repmat(u.domain.cellsize.y(3:end)', Nr, 1);
DTHETAs = repmat(u.domain.cellsize.y(1:end-2)', Nr, 1);
DTHETAp = repmat(u.domain.cellsize.y(2:end-1)', Nr, 1);
rp = repmat(u.domain.cellcenters.x, 1, Ntetta);
rf = repmat(u.domain.facecenters.x, 1, Ntetta);
re = rf(2:Nr+1,:);         rw = rf(1:Nr,:);

% define the vectors to store the sparse matrix data
iix = zeros(3*(Nr+2)*(Ntetta+2),1);	iiy = zeros(3*(Nr+2)*(Ntetta+2),1);
jjx = zeros(3*(Nr+2)*(Ntetta+2),1);	jjy = zeros(3*(Nr+2)*(Ntetta+2),1);
sx = zeros(3*(Nr+2)*(Ntetta+2),1);	sy = zeros(3*(Nr+2)*(Ntetta+2),1);
mnx = Nr*Ntetta;	mny = Nr*Ntetta;

% reassign the east, west, north, and south velocity vectors for the
% code readability
ue = re.*u.xvalue(2:Nr+1,:)./(DRp+DRe);
uw = rw.*u.xvalue(1:Nr,:)./(DRp+DRw);
vn = u.yvalue(:,2:Ntetta+1)./(rp.*(DTHETAp+DTHETAn));
vs = u.yvalue(:,1:Ntetta)./(rp.*(DTHETAp+DTHETAs));

% calculate the coefficients for the internal cells
AE = reshape(ue,mnx,1);
AW = reshape(-uw,mnx,1);
AN = reshape(vn,mny,1);
AS = reshape(-vs,mny,1);
APx = reshape((ue.*DRe-uw.*DRw)./DRp,mnx,1);
APy = reshape((vn.*DTHETAn-vs.*DTHETAs)./DTHETAp,mny,1);

% build the sparse matrix based on the numbering system
rowx_index = reshape(G(2:Nr+1,2:Ntetta+1),mnx,1); % main diagonal x
iix(1:3*mnx) = repmat(rowx_index,3,1);
rowy_index = reshape(G(2:Nr+1,2:Ntetta+1),mny,1); % main diagonal y
iiy(1:3*mny) = repmat(rowy_index,3,1);
jjx(1:3*mnx) = [reshape(G(1:Nr,2:Ntetta+1),mnx,1); reshape(G(2:Nr+1,2:Ntetta+1),mnx,1); reshape(G(3:Nr+2,2:Ntetta+1),mnx,1)];
jjy(1:3*mny) = [reshape(G(2:Nr+1,1:Ntetta),mny,1); reshape(G(2:Nr+1,2:Ntetta+1),mny,1); reshape(G(2:Nr+1,3:Ntetta+2),mny,1)];
sx(1:3*mnx) = [AW; APx; AE];
sy(1:3*mny) = [AS; APy; AN];

% build the sparse matrix
kx = 3*mnx;
ky = 3*mny;
Mx = sparse(iix(1:kx), jjx(1:kx), sx(1:kx), (Nr+2)*(Ntetta+2), (Nr+2)*(Ntetta+2));
My = sparse(iiy(1:ky), jjy(1:ky), sy(1:ky), (Nr+2)*(Ntetta+2), (Nr+2)*(Ntetta+2));
M = Mx + My;
