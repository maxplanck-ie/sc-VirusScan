import pandas as pd
from box import Box
from pathlib import Path

OUTDIR = Path(config["output_dir"])

METADATA = pd.read_csv(
    (Path(workflow.basedir) / config["samples"]), 
    dtype=str,
    ).set_index(["sample"], drop=False)


def _get_default(param):
    "Return an input function (taking wildcards) that takes the given "
    " parameter `param`, for a particular sample, otherwise looks up 
    "config["defaults"][param] if it is not specified."
    def inner(wc):
        val = METADATA.loc[str(wc.sample)][param]
        if pd.isnan(val):
            if param in config["defaults"]:
                return config["defaults"][param]
            else:
                raise Exception(
                    "Error: param {param} not found for sample {sample} in "
                    "either config.yaml or samples.csv"
                )
        return val
    return inner


def create_path_accessor(prefix: Path = OUTDIR) -> Box:
    """Create a Box to provide '.' access to hierarchy of paths"""
    data = yaml.load(Path(config["file_layout"]).open(), Loader=yaml.SafeLoader)
    paths = {}
    for directory in data.keys():
        paths[directory] = {}
        for file_alias, file_name in data[directory].items():
            p = str(prefix / directory / file_name)
            paths[directory][file_alias] = str(p)
    return Box(paths, frozen_box=True)
