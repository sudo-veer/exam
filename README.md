```bash
# 1. Activate the environment (replace 'base' if using a custom env)
conda activate base 
```
```bash
# 2. Install the package that links Conda to Jupyter
conda install ipykernel -y
```
```bash
# Register the Conda environment as a selectable kernel.
# NOTE: The --name must match your Conda environment name (e.g., 'base').
python -m ipykernel install --user --name base --display-name "Python (base)"
```

```bash
#if some other case study for olap comes just give the prompt here to pretrained gpt
https://chatgpt.com/share/68ff4a42-47e4-800d-9b50-791a4f6f7fde
