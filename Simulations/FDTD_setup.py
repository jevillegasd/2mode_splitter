
######## IMPORTS ########
# General purpose imports
import lumapi
import numpy as np
from scipy.constants import c

dev_params = {   'wg01': 1e-6,
                 'wg02': 0.5e-6,
                 'spacing':0.35e-6,
                 'length': 3e-6}
                 
def y_branch_TE0(fdtd):
    #y_branch_init_(fdtd)   
    # Update source for the mode of interest
    fdtd.select('FDTD') 
    fdtd.select('FDTD::ports::port 1')
    fdtd.set('mode selection','user select')
    fdtd.set('selected mode numbers', 1)
    fdtd.updateportmodes()
    print('Selected Input Mode: ' + str(fdtd.get('selected mode numbers')))
        

def y_branch_TE1(fdtd):
    #y_branch_init_(fdtd)
    # Update source for the mode of interest
    fdtd.select('FDTD')
    fdtd.select('FDTD::ports::port 1')
    fdtd.set('mode selection', 'user select')
    fdtd.set('selected mode numbers', 2)
    fdtd.updateportmodes()
    print('Selected Input Mode: ' + str(fdtd.get('selected mode numbers')))

def y_branch_init_(fdtd): 
    ## CLEAR SESSION
    fdtd.switchtolayout()
    fdtd.selectall()
    fdtd.delete()
    
    ## SIM PARAMS
    fdtd_params = {}
    fdtd_params['size_x']=4e-6
    fdtd_params['size_y']=4e-6
    fdtd_params['size_z']=1.2e-6  
    
    mesh_x=50e-9
    mesh_y=10e-9
    mesh_z=10e-9
    finer_mesh_size_x = (2/3)*fdtd_params['size_x'] #Also used for the opt_fields monitor
    finer_mesh_size_y = (5/6)*fdtd_params['size_y']
    finer_mesh_size_z =0.22e-6
    mesh_accuracy=3
    lam_c = 1.550e-6   #Simulation Wavelength
    
    # MATERIAL
    opt_material=fdtd.addmaterial('Dielectric')
    fdtd.setmaterial(opt_material,'name','Si: non-dispersive')
    n_opt = fdtd.getindex('Si (Silicon) - Palik',c/lam_c)
    fdtd.setmaterial('Si: non-dispersive','Refractive Index',n_opt)
    
    sub_material=fdtd.addmaterial('Dielectric')
    fdtd.setmaterial(sub_material,'name','SiO2: non-dispersive')
    n_sub = fdtd.getindex('SiO2 (Glass) - Palik',c/lam_c)
    fdtd.setmaterial('SiO2: non-dispersive','Refractive Index',n_sub)
    fdtd.setmaterial('SiO2: non-dispersive',"color", np.array([0, 0, 0, 0]))
    
    ## GEOMETRY
    
    #INPUT WAVEGUIDE
    
    fdtd.addrect()
    fdtd.set('name','input wg')
    fdtd.set('x span',3e-6)
    fdtd.set('y span',dev_params['wg01'])
    fdtd.set('z span',220e-9)
    fdtd.set('y',0)
    fdtd.set('x',-(1.5e-6+dev_params['length']/2))
    fdtd.set('z',0)
    fdtd.set('material','Si: non-dispersive')
    
    #OUTPUT WAVEGUIDES
    
    fdtd.addrect()
    fdtd.set('name','output wg top')
    fdtd.set('x span',3e-6)
    fdtd.set('y span',dev_params['wg02'])
    fdtd.set('z span',220e-9)
    fdtd.set('y',(dev_params['wg02']+dev_params['spacing'])/2)
    fdtd.set('x',1.5e-6+dev_params['length']/2)
    fdtd.set('z',0)
    fdtd.set('material','Si: non-dispersive')
    
    fdtd.addrect()
    fdtd.set('name','output wg bottom')
    fdtd.set('x span',3e-6)
    fdtd.set('y span',dev_params['wg02'])
    fdtd.set('z span',220e-9)
    fdtd.set('y',-(dev_params['wg02']+dev_params['spacing'])/2)
    fdtd.set('x',1.5e-6+dev_params['length']/2)
    fdtd.set('z',0)
    fdtd.set('material','Si: non-dispersive')
    
    # Substrate and cladding
    fdtd.addrect()
    fdtd.set('name','sub')
    fdtd.set('x span',8e-6)
    fdtd.set('y span',8e-6)
    fdtd.set('z span',5e-6)
    fdtd.set('y',0)
    fdtd.set('x',0)
    fdtd.set('z',0)
    fdtd.set('z min',-2e-6)    
    fdtd.set('material','SiO2: non-dispersive')
    fdtd.set('override mesh order from material database',1)
    fdtd.set('mesh order',3)
    fdtd.set('alpha',0.8)
    
    ## FDTD
    fdtd.addfdtd()
    fdtd.set('mesh accuracy',mesh_accuracy)
    fdtd.set('dimension','3D')
    fdtd.set('x min',-fdtd_params['size_x']/2)
    fdtd.set('x max',fdtd_params['size_x']/2)
    fdtd.set('y min',-fdtd_params['size_y']/2)
    fdtd.set('y max',fdtd_params['size_y']/2)
    fdtd.set('z min',-fdtd_params['size_z']/2.0)
    fdtd.set('z max',fdtd_params['size_z']/2.0)
    fdtd.set('force symmetric y mesh',1)
    fdtd.set('force symmetric z mesh',0)
    fdtd.set('z min bc','PML')
    fdtd.set("background index",1)
    #fdtd.set("index",1)
    
    ## MESH 
    fdtd.addmesh()
    fdtd.set('x',0)
    fdtd.set('x span',finer_mesh_size_x)
    fdtd.set('y',0)
    fdtd.set('y span',finer_mesh_size_y)
    fdtd.set('z',0)
    fdtd.set('z span',finer_mesh_size_z)
    fdtd.set('dx',mesh_x)
    fdtd.set('dy',mesh_y)
    fdtd.set('dz',mesh_z)
    
    
    ## FIELDS MONITOR 
    fdtd.addpower()
    fdtd.set('name','m_fields')
    fdtd.set('monitor type','2D Z-Normal')
    fdtd.set('x',0)
    fdtd.set('x span',finer_mesh_size_x)
    fdtd.set('y',0)
    fdtd.set('y span',finer_mesh_size_y)
    fdtd.set('z',0)
    
    ## SOURCE PORT
    fdtd.select('FDTD')
    fdtd.addport()
    fdtd.set('x',-1.6e-6)
    fdtd.set('direction', 'Forward')
    fdtd.set('mode selection', 'user select')
    fdtd.set('selected mode numbers', 1)
    fdtd.set('injection axis','x-axis')
    fdtd.set('y',0)
    fdtd.set("y span",fdtd_params['size_y'])
    fdtd.set('x',-fdtd_params['size_x']/2+0.2e-6)

    ## OUTPUT PORT
    fdtd.addport()
    fdtd.set('x',1.6e-6)
    fdtd.set('direction', 'Backward')
    fdtd.set('mode selection', 'user select')
    fdtd.set('number of field profile samples',3)
    fdtd.set('selected mode numbers', np.array([1,2]))
    fdtd.set('injection axis','x-axis')
    fdtd.set('y',0)
    fdtd.set("y span",fdtd_params['size_y'])
    fdtd.set('x',-fdtd_params['size_x']/2+0.2e-6)
    
    fdtd.select('FDTD::ports')
    fdtd.set('monitor frequency points',11)
    fdtd.setglobalsource('center wavelength',1.55e-6)
    fdtd.setglobalsource('wavelength span',0.1e-6)


if __name__ == "__main__":
    fdtd = lumapi.FDTD(hide = False)
    y_branch_init_(fdtd)
    y_branch_TE1(fdtd)
    input('Press Enter to escape...')    
    
    
    
    
    