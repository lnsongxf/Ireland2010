% Replicate Ireland 2010
% Code by Patrick Moran (patedm@gmail.com)

%=========================================================================%
%                    DECLARATION OF VARIABLES                             %
%=========================================================================%

var
a
y
lambda 		$\lambda$
r
pi 			$\pi$
e
g
zhat		$z^{hat}$
q
x
;

varexo 
epsilon_a    ${\epsilon_a}$
epsilon_e    ${\epsilon_e}$
epsilon_z    ${\epsilon_z}$
epsilon_r    ${\epsilon_r}$
;

%=========================================================================%
%%%%                    DECLARATION OF PARAMETERS                      %%%%
%=========================================================================%
 
parameters 
% NOT ESTIMATED
z           ${z}$ 
beta        ${\beta}$ 
psi         ${\psi}$ 			% Ireland notes that this always goes to 0 in estimation. Will this still be true?
rhor        ${\rho_r}$ 
rhox        ${\rho_x}$ 

% ESTIMATED
gamma       ${\gamma}$ 
alpha       ${\alpha}$ 
rhop        ${\rho_\pi}$
rhog        ${\rho_g}$ 
rhoa        ${\rho_a}$ 
rhoe        ${\rho_e}$ 
siga        ${\sigma_a}$ 
sige        ${\sigma_e}$ 
sigz        ${\sigma_z}$ 
sigr        ${\sigma_r}$
;

%=========================================================================%
%%%%                     PARAMETERS' VALUES                            %%%%
%=========================================================================%

z = 1.0046;
beta = 0.9987;
psi = 0.10;
rhor = 1;
rhox = 0;

gamma = 0.3904;
alpha = 0.0000; 
rhop = 0.4153;
rhog = 0.1270;
rhoa = 0.9797;
rhoe = 0.0000;

siga = 0.0868;
sige = 0.0017;
sigz = 0.0095;
sigr = 0.0014;

%=========================================================================%
%%%%                     EQUILIBRIUM CONDITIONS                        %%%%
%=========================================================================%
model;

a = rhoa * a(-1) + epsilon_a;

(z-beta*gamma) * (z - gamma) * lambda = gamma*z*y(-1) - (z^2 + beta*gamma^2)*y + beta*gamma*z*y(+1) + (z-beta*gamma*rhoa)*(z-gamma)*a - gamma*z*zhat;

lambda = r + lambda(+1) - pi(+1);

e = rhoe*e(-1) + epsilon_e;

zhat = epsilon_z;

(1+beta*alpha)*pi = alpha*pi(-1) + beta*pi(+1) - psi*lambda + psi*a + e;

r - r(-1) = rhop*pi + rhog*g + epsilon_r;

g = y - y(-1) + zhat;

0 = gamma*z*q(-1) - (z^2 + beta*gamma^2)*q + beta*gamma*z*q(+1) +beta*gamma*(z-gamma)*(1-rhoa)*a - gamma*z*zhat;

x = y - q;

end; 

write_latex_dynamic_model;
write_latex_static_model;

%===================================================================%
%%%%             INITIAL CONDITIONS FOR STEADY STATE             %%%%
%===================================================================%

initval;
    a = 0;
    y = 0;
    lambda = 0;
    r = 0;
    pi = 0;
    e = 0;
    g = 0;
    zhat = 0;
    q = 0;
    x = 0;
end;

%=========================================================================%
%%%%                              RUN                                  %%%%
%=========================================================================%

shocks;
var epsilon_a;
stderr 0.0868;

var epsilon_e;
stderr 0.0017;

var epsilon_z;
stderr 0.0095;

var epsilon_r;
stderr 0.0014;
end;

steady(solve_algo  = 1, maxit = 50000);
check;

% Set seed for simulation
% set_dynare_seed(092677);

% stoch_simul(order=1,periods=108, irf=10);
% stoch_simul(order=1,periods=600, irf=10, nograph, nodisplay, nocorr, nomoments);

% In a maximum likelihood estimation, each line follows this syntax:
% PARAMETER_NAME, INITIAL_VALUE [, LOWER_BOUND, UPPER_BOUND ];
% stderr VARIABLE_NAME 

% INITIAL VALUE (estimation results from Ireland 2010)
% estimated_params;
% gamma,       			0.3904,		0,		1;
% alpha,       			0.0000,		0,		1;
% rhop,        			0.4153;
% rhog,        			0.1270;
% rhoa,        			0.9797,		0,		1;
% rhoe,        			0.0000,		0,		1;
% 
% stderr epsilon_a,        0.0868;
% stderr epsilon_e,        0.0017;
% stderr epsilon_z,        0.0095;
% stderr epsilon_r,        0.0014;
% end;

% INITIAL VALUE (init value used in Ireland code)
estimated_params;
gamma,                  0.5,		0,		1;
alpha,                  0.5,		0,		1;
rhop,                   0.25;
rhog,                   0.05;
rhoa,                   0.75,		0,		1;
rhoe,                   0.25,		0,		1;

stderr epsilon_a,        0.01,      0,      1;
stderr epsilon_e,        0.001,     0,      1;
stderr epsilon_z,        0.01,      0,      1;
stderr epsilon_r,        0.0025,    0,      1;
end;

% OBSERVALBE VARIABLES
% output growth rate, the inflation rate, and the short-term nominal interest rate
varobs g pi r;

estimation(
    datafile = IrelandData,
    nobs = 108,
    mode_compute=1,
    prefilter = 0,
    optim = ('Display','iter','LargeScale','off','MaxFunEvals',10000,'MaxIter',10000)
);

% In Ireland 2010, he uses fminunc (this would be mode_compute = 3)