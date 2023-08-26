import os, sys
sys.path.append("C:\\Program Files\\Lumerical\\v221\\api\\python\\")

import numpy as np
import scipy as sp
import matplotlib.pyplot as plt
import lumapi
sys.path.append(os.path.dirname(__file__))


from FDTD_setup import y_branch_init_, y_branch_TE1 , y_branch_TE0
          
######## BASE SIMULATION ########
dev_params = {   'wg01': 1e-6,
                 'wg02': 0.5e-6,
                 'spacing':0.35e-6,
                 'length': 3e-6}
                 
ipt_wg_width = dev_params['wg01']
opt_wg_width = dev_params['wg02']        
                 
######## DIRECTORY FOR GDS EXPORT #########
example_directory = os.getcwd()

######## OPTIMIZABLE GEOMETRY ########
# The class FunctionDefinedPolygon needs a parameterized Polygon (with points ordered
# in a counter-clockwise direction). Here the geometry is defined by 10 parameters defining
# the knots of a spline, and the resulting Polygon has 200 edges, making it quite smooth.

# Define the span and number of points
initial_points_x = np.linspace(-dev_params['length']/2, dev_params['length']/2, 11)
initial_points_y = np.linspace(dev_params['wg01']/2, dev_params['spacing']/2+dev_params['wg02'], initial_points_x.size)
scaling_factor = 1

def asymmetric_splitter(params,sigma_w):
    ''' Defines a taper where the paramaters are the y coordinates of the nodes of a cubic spline. '''
    np.savetxt('./last_parameters.txt', params)
    ## Include two set points based on the initial guess. The should attach the optimizeable geometry to the input and output 
    ran1 = (np.random.rand(11)*sigma_w)
    ran2 = (np.random.rand(11)*sigma_w)

    points_x = np.concatenate(([initial_points_x.min() - 0.01e-6], initial_points_x, [initial_points_x.max() + 0.01e-6]))
    points_y = np.concatenate(([initial_points_y.min()], params+ran1, [initial_points_y.max()]))
    points_y2 = np.concatenate(([initial_points_y.min()], params+ran2, [initial_points_y.max()]))
    ## Up sample the polygon points for a smoother curve. Some care should be taken with interp1d object. Higher degree fit
    # "cubic", and "quadratic" can vary outside of the footprint of the optimization. The parameters are bounded, but the
    # interpolation points are not. This can be particularly problematic around the set points.
    n_interpolation_points = 100
    polygon_points_x = np.linspace(min(points_x), max(points_x), n_interpolation_points)
    interpolator = sp.interpolate.interp1d(points_x, points_y, kind = 'cubic')
    polygon_points_y = interpolator(polygon_points_x)

    interpolator2 = sp.interpolate.interp1d(points_x, points_y2, kind = 'cubic')
    polygon_points_y2 = interpolator2(polygon_points_x)

    ### Zip coordinates into a list of tuples, reflect and reorder. Need to be passed ordered in a CCW sense 
    
    polygon_points_up = [(x, y) for x, y in zip(polygon_points_x, polygon_points_y)]
    polygon_points_down = [(x, -y) for x, y in zip(polygon_points_x, polygon_points_y2)]
    polygon_points = np.array(polygon_points_up[::-1] + polygon_points_down)
    return polygon_points

#Load from 2D results if availble
try:
    y_points = np.loadtxt('./parameters.txt')
except Exception as e: 
    print("Couldn't find the file containing 2D optimization parameters. Starting with default parameters")
    print(e)
    y_points = initial_points_y


file = open('save.txt', 'a')
file.write('--------------------------------\n')
file.write('[S21_TE0, S31_TE0, XT_TE0, S21_TE1, S31_TE1,XT_TE1]'+'\n')
file.close()
with lumapi.FDTD(hide = False) as fdtd:
    ss_w = np.linspace(0.01,0.2,10)*1e-6
    S_TE0 = np.empty([10,10])
    S_TE1 = np.empty([10,10])
    X_TE0 = np.empty([10,10])
    X_TE1 = np.empty([10,10])
    
    fdtd.cd(example_directory)
    i = 0

    y_branch_init_(fdtd)
    fdtd.save("y_branch_base")
    for sigma_w in ss_w:
        S_TE0_ = np.empty(10)
        S_TE1_ = np.empty(10)
        X_TE0_ = np.empty(10)
        X_TE1_ = np.empty(10)
        for i_test in range(0, 10):
            fdtd.switchtolayout()
            y_branch_TE0(fdtd)    
            try:
                fdtd.select('polygon')
                fdtd.delete()
            except:
                print('Nothing to delete')

            fdtd.addpoly(vertices = asymmetric_splitter(y_points / scaling_factor,sigma_w))
            fdtd.set('x', 0.0)
            fdtd.set('y', 0.0)
            fdtd.set('z', 0.0)
            fdtd.set('z span', 220e-9)
            fdtd.set('material','Si: non-dispersive')
            fdtd.run()

            fdtd.save("y_branch_TE0")
            #fdtd.load("y_branch_TE0")
            try:
                S_ = fdtd.getresult('FDTD::ports::port 2','S')
                S = S_.get('S')
                S21_TE0 = np.power(abs(S[6][0]),2)
                S31_TE0 = np.power(abs(S[6][1]),2)
            except:
                S21_TE0 = 0
                S31_TE0 = 2
            XT_TE0 = 10*np.log10(S31_TE0/S21_TE0)
            S_TE0_[i_test-1]=(S21_TE0)
            X_TE0_[i_test-1]=(XT_TE0)

            fdtd.switchtolayout()
            
            y_branch_TE1(fdtd) 
            fdtd.run()
            fdtd.save("y_branch_TE1")

            #fdtd.load("y_branch_TE1")
            try:
                S_ = fdtd.getresult('FDTD::ports::port 2','S')
                S = S_.get('S')
                S21_TE1 = np.power(abs(S[6][0]),2)
                S31_TE1 = np.power(abs(S[6][1]),2)
            except:
                S21_TE1 = 0
                S31_TE1 = 2
            XT_TE1 = 10*np.log10(S21_TE1/S31_TE1)
            S_TE1_[i_test-1]=(S31_TE1)
            X_TE1_[i_test-1]=(XT_TE1)
            export_str = np.array2string(np.array([sigma_w, S21_TE0, S31_TE0, XT_TE0, 
                                                   S21_TE1, S31_TE1,XT_TE1 ]))+'\n'
            file = open('save.txt', 'a')
            file.write(export_str)
            print(export_str)
            file.close()
            
        mu_XTE0 = np.average(X_TE0_)
        mu_XTE1 = np.average(X_TE1_)
        sig_XTE0 = np.std(X_TE0_)
        sig_XTE1 = np.std(X_TE1_)

        print('sigma_w=' + str(sigma_w)+ '; Crosstalk: '+ 
              'X_TE0='+ str(mu_XTE0) + '+/- ' + str(sig_XTE0) +
              'X_TE1='+ str(mu_XTE1) + '+/- ' + str(sig_XTE1) + '\n')
        
        file = open('avg.txt', 'a')
        file.write(np.array2string(np.array([mu_XTE0, sig_XTE0, mu_XTE1, sig_XTE1]))+'\n')
        file.close()

        S_TE0[0:10][i] = S_TE0_
        S_TE1[0:10][i] = S_TE1_
        X_TE0[0:10][i] = X_TE0_
        X_TE1[0:10][i] = X_TE1_    
        i = i+1


    
