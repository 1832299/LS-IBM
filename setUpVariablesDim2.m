function [StateVar,VARIABLES,DOMAIN,BC,IBM,LS, LSCase]= setUpVariablesDim
%% =========================== Domain size ================================

diamcyl = 1;                  % Diameter of cylinders

nrgrainx = 1;                 % Number of Cylinders in one row
nrgrainy = 1;

S = 2*diamcyl;                % Space between centers of objects

freeEast = 499*diamcyl;        %exit length after cylinders
freeWest = 499*diamcyl;      % entrance length after
freeNorth = 95*diamcyl;
freeSouth = 95*diamcyl;

lx = freeWest + nrgrainx*diamcyl + (nrgrainx-1)*S + ...
    freeEast; % Length in x direction
ly = freeSouth + nrgrainy*diamcyl + (nrgrainy-1)*S + ...
    freeNorth; % Length in x direction

% ly = 7*diamcyl;             % Length of computational domain in y dir





%% ======================== Additional variables ==========================
% - Re is in fact kinematic viscosity
% - Pe is 1/(diffusion coeffcient)
Re = 1;      % Re is the Kinematic viscosity in dimensional case
uinflow = 1;
Pe = 240;           
D = 1/Pe;
phi_inlet = 1;
phi_init = 1;
density = 1;
dimensional = 1;
%% =============================== BCs ====================================

%% velocities and flow



% -alpha(dphi/dn_w)-beta phi=q
 
q = 0;
alpha = 0;
beta = 1;

BQu = 0;
BQv = 0;

BC_e_u = 3;
BC_w_u = 1;
BC_n_u = 3;         %BC_n=1 ==> Dirichlet,   BC_n=3 ==> Neumann
BC_s_u = 3;         %BC_s=1 ==> Dirichlet,   BC_s=3 ==> Neumann


BC_n_v = 3;         %BC_n=1 ==> Dirichlet,   BC_n=3 ==> Neumann
BC_s_v = 3;         %BC_s=1 ==> Dirichlet,   BC_s=3 ==> Neumann
BC_e_v = 3;
BC_w_v = 1;

BC_n_p = 3;         %BC_n=1 ==> Dirichlet,   BC_n=3 ==> Neumann
BC_s_p = 3;         %BC_s=1 ==> Dirichlet,   BC_s=3 ==> Neumann
BC_e_p = 3;
BC_w_p = 3;

P0_e = 0;
%% Transport
% -alpha(dphi/dn_w)-beta phi=q

q_phi = 0;
alpha_phi = 1;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   ;
beta_phi = 1000;     % beta is K in the reaction
BQp = 0;

BC_e_phi=1;
BC_w_phi=3;
BC_n_phi=3;         %BC_n=1 ==> Dirichlet,   BC_n=3 ==> Neumann
BC_s_phi=3;         %BC_s=1 ==> Dirichlet,   BC_s=3 ==> Neumann



%% ========================= Objects ======================================

% yc=ly/2;
xcent = freeWest+diamcyl/2:2+diamcyl:lx-freeEast-diamcyl/2 ;
ycent = freeSouth+diamcyl/2:2+diamcyl:ly-freeNorth-diamcyl/2;
% for i=1:nrgrainx
%     xc(i)=entlength+(i-1)*S;
% end
phi_inside_u=0;                           % concen inside of objects
phi_inside_phi=q_phi;
[xc,yc] =deal(zeros(nrgrainx,nrgrainy));
for i=1:nrgrainx
    for j=1:nrgrainy
        xc(i,j) = xcent(i);
        yc(i,j) = ycent(j);
    end
end
        




%% ======================== Coordinates ===================================
Grid.r = 1.1;
Grid.expon = 1;
Grid.A = 2;
Grid.dvdxdy = 2.5;
Grid.uniform = 0.1;
Grid.zoomedAreax = 1.5;
Grid.zoomedAreay = 1.5;
Grid.Lx_l = 1.5/50;
Grid.Ly_b = 0.5/50;
Grid.lengthUnit = diamcyl;

[DOMAIN]=Coordinates(lx,ly,diamcyl,Grid);
%% ========================= Time Steps ===================================

dt_man=1e-3;                             %% Arbitrary time step
dt_diff =  Re/((1/min(min(DOMAIN.dxu)))^2 + (1/min(min(DOMAIN.dyu)))^2); %% Diffisiun time step                  
dt_cour = 1/sqrt(2*(uinflow^2)*...
    ((1/min(min(DOMAIN.dxu)))^2 + (1/min(min((DOMAIN.dyu)))^2))); % Courant time
Dt=[dt_man,dt_diff,dt_cour];
% dt=min(Dt);
dt=dt_man;
% dt=0.008;
%% =============== Define marix variables / storage =======================
imax=DOMAIN.imax;
jmax=DOMAIN.jmax;
%U- velocity ---------------------
U=zeros(imax,jmax+1);

U_a=zeros(1,jmax+1);
U_b=zeros(1,jmax+1);
U_c=zeros(imax,1);
U_d=zeros(imax,1);

%V- velocity ----------------------
V=zeros(imax+1,jmax);

V_a=zeros(1,jmax);
V_b=zeros(1,jmax);
V_c=zeros(1,imax+1);
V_d=zeros(1,imax+1);


%Scalars -------------------------
P=zeros(imax+1,jmax+1);
phi=zeros(imax+1,jmax+1);

phi_a=zeros(1,jmax+1);
phi_b=zeros(1,jmax+1);
phi_c=zeros(1,jmax+1);
phi_d=zeros(1,jmax+1);

%% ================= Initialization of matrix fields ======================






%% =================== initialize LS

LSCase.case = 3;  %1 ==> circles, 2 ==> flat fracture, 3 ==> rough fracture
%%% ======= cylinder ===============
LSCase.xc = xc;
LSCase.yc = yc;
LSCase.diamcyl = diamcyl;
%%% ======= simple fracture ===============
h = 4.5;
LSCase.h = h;
%%
%%% ======= rough fracture ===============
xt = 0:min(min(DOMAIN.dxp))/10:DOMAIN.lx; % x-fracture
b = 100;  % half fracture width
lambda = 40;   % wave length
a = 0.5 * lambda; % amplitude of the roughness 
x_0 = 0 *lambda; % phase displacement 
%%%=========boundary generating function =====================
fy = @(x, a, lambda, x_0)a*sin(2*pi/lambda * (x-x_0));
LSCase.BoundaryCurve.yt = b/2 + fy(xt, a, lambda, x_0);
LSCase.BoundaryCurve.yb = -b/2 - fy(xt, a, lambda, x_0);
%%%============================================================

%%
LSCase.BoundaryCurve.a = a;
LSCase.BoundaryCurve.lambda = lambda;
LSCase.BoundaryCurve.b = b;
LSCase.BoundaryCurve.x_0 = x_0;
LSCase.BoundaryCurve.xt = xt;

LSCase.BoundaryCurve.boundfunctionTop = ...
    @(x, a, lambda, x_0, b) b/2 + a*sin(2*pi/lambda * (x-x_0));
LSCase.BoundaryCurve.bFunctionBottom = ...
    @(x, a, lambda, x_0, b) -b/2 - a*sin(2*pi/lambda * (x-x_0));

LSCase.BoundaryCurve.endBotIndx = ceil(length(DOMAIN.yp)/2);


psi = LSInitialize(DOMAIN, LSCase);

% psi = zeros(imax+1,jmax+1);
% for i=1:imax+1
%     for j=1:jmax+1
%         d = sqrt( (DOMAIN.xp(i)-xc).^2 + (DOMAIN.yp(j)-yc).^2 )-diamcyl/2;
%         center = min(min(abs(d)));
%         [I,J,~] = find(abs(d) == center);
%         psi(i,j) = d(I(1),J(1));
%         
%     end
% end
psiU = interp2(DOMAIN.yp.*ones(imax+1,1), ones(jmax+1,1)'.*DOMAIN.xp', ...
    psi ,DOMAIN.yu.*ones(imax,1), ones(jmax+1,1)'.*DOMAIN.xu');

psiV = interp2(DOMAIN.yp.*ones(imax+1,1), ones(jmax+1,1)'.*DOMAIN.xp', ...
    psi ,DOMAIN.yv.*ones(imax+1,1), ones(jmax,1)'.*DOMAIN.xv');


%% initialize U, V, phi

U(:,:)=uinflow;
V(:,:) = 0;

U = double(psiU>0).*U;
V = double(psiV>0).*V;

U(1,:) = uinflow * (U(1,:)>0);
U_a(:)=U(1,:);
U_c(:)=uinflow;
U_d(:)=uinflow;





phi(:,:)=phi_init;
phi = double(psi>0).*phi;
phi_a(1,:) =phi_inlet * phi(1,:);

phi_old=phi;


%% interface velocity parameters
molarVol = 36.9;
interfaceVelocityCoeff = beta_phi * molarVol/D;
methodInterfaceVelocity = 2;    % chooses the denominator of the velocity, 1 for conditionally stable, 2 for stable
%% LS solver variables

fac = 0.5;    % dta factor 
dtau = fac*min(min(DOMAIN.dxp));  % psedue time step

n_iter_ReLS = 4;

TimeSchemeLS = "RK3";
TimeSchemeRLS = "RK3";

% psi = sqrt( (DOMAIN.Xp-xc).^2 + (DOMAIN.Yp-yc).^2 )-diamcyl/2;
% LS = double(d>0)*d + double(d<0)*(d-r);

%% ========================== Time integration ============================

alpha_u=1;
alpha_v=alpha_u;
alpha_p=1;

VARIABLES = struct('D',D,'Re',Re,'density', density,'molarVol',molarVol,...
    'dimensional',dimensional,...
    'intVelCoeff',interfaceVelocityCoeff,'intVelMethod',methodInterfaceVelocity,...
    'alpha_u',alpha_u,'alpha_v',alpha_v,...
    'alpha_p',alpha_p,'dt',dt,'dtVec',Dt,'Da',beta_phi,'Pe',Pe,...
    'n_iter_ReLS',n_iter_ReLS,'dtau',dtau,'TimeSchemeLS',TimeSchemeLS,...
    'TimeSchemeRLS',TimeSchemeRLS);


BC = struct('U_a',U_a,'U_b',U_b,'U_c',U_c,'U_d',U_d,...
    'V_a',V_a,'V_b',V_b,'V_c',V_c,'V_d',V_d,...
    'phi_a',phi_a,'phi_b',phi_b,'phi_c',phi_c,'phi_d',phi_d,...
    'BC_e_u',BC_e_u,'BC_w_u',BC_w_u,'BC_n_u',BC_n_u,'BC_s_u',BC_s_u,...
    'BC_e_v',BC_e_v,'BC_w_v',BC_w_v,'BC_n_v',BC_n_v,'BC_s_v',BC_s_v,...
    'BC_e_phi',BC_e_phi,'BC_w_phi',BC_w_phi,'BC_n_phi',BC_n_phi,...
    'BC_s_phi',BC_s_phi, ...
    'BC_n_p', BC_n_p, 'BC_s_p',BC_s_p, 'BC_w_p',BC_w_p, 'BC_e_p',BC_e_p, ...
    'P0_e', P0_e);

IBM = struct('q',q,'alpha',alpha,'beta',beta,'q_phi',q_phi,'alpha_phi',...
    alpha_phi,'beta_phi',beta_phi,...
    'phi_inside_u',phi_inside_u,'phi_inside_phi',phi_inside_phi,...
    'xc',xc,'yc',yc,'diamcyl',diamcyl,'nrgrainx',nrgrainx,...
    'nrgrainy',nrgrainy,'BQu',BQu,'BQv',BQv,'BQp',BQp, 'treshold', 100 *eps);

StateVar = struct('U',U,'V',V,'P',P,'phi_old',phi_old);
StateVar.P_cor_vec = zeros(1,(DOMAIN.imax-1)*(DOMAIN.jmax-1))';

LS = struct('psi',psi);
[LS] = LSnormals(LS,DOMAIN);

StateVar.U_old = StateVar.U;
StateVar.V_old = StateVar.V;
StateVar.P_old = StateVar.P;

% StateVar.U_star = StateVar.U;
% StateVar.V_star = StateVar.V;
% StateVar.U_star_old = StateVar.U_star;
% StateVar.V_star_old = StateVar.V_star;
        
%% ==============================
StateVar.phi = StateVar.phi_old;
VARIABLES.LSband = 10*min(min(DOMAIN.dxp));
VARIABLES.nLSupdate = 10;
VARIABLES.dtLS = VARIABLES.nLSupdate * VARIABLES.dt;

end