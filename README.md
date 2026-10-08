# Recitation 3 notebooks

Start Jupyter in the background:

```bash
make up
```

The first run creates `.venv` and installs JupyterLab. Open the URL printed
in your terminal, then open `recitation_3.ipynb` or create a new notebook.
Python 3 with `venv` support, GNU Make, and Linux `setsid` are required.

Stop Jupyter and its notebook kernels:

```bash
make down
```

Save your notebook before stopping. Notebook files remain in this folder.
Running either command again is safe. `make down` only stops servers belonging
to this folder, using its own Jupyter runtime directory.

To use another port, run `make up PORT=8889` after stopping the server.
If the requested port is busy, Jupyter chooses an available port and prints it.
Jupyter listens on `127.0.0.1`; use the token URL printed by `make up` to log in.
Server logs are in `.jupyter/server.log`.

JupyterLab installation reference: [official documentation](https://jupyterlab.readthedocs.io/en/stable/getting_started/installation.html).
