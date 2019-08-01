#!/bin/bash

cd /notes
/opt/conda/bin/jupyter lab build
/opt/conda/bin/jupyter lab --ip=0.0.0.0 --port=49161 --no-browser --allow-root

# jupyter config に　c.NotebookApp.contents_manager_class = "jupytext.TextFileContentsManager"　を追加しなくていい？