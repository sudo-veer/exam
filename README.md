```bash
# 1. Activate the environment (replace 'base' if using a custom env)
conda activate base 

# 2. Install the package that links Conda to Jupyter
conda install ipykernel -y

# Register the Conda environment as a selectable kernel.
# NOTE: The --name must match your Conda environment name (e.g., 'base').
python -m ipykernel install --user --name base --display-name "Python (base)"
