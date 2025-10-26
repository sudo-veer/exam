# 1. Activate the target environment (e.g., 'base' or your custom environment name)
conda activate base 

# 2. Install the ipykernel package
conda install ipykernel -y

# Register the Conda environment as a selectable kernel in Jupyter
python -m ipykernel install --user --name base --display-name "Python (base)"

# after this change the kernel and execute the code it should work
