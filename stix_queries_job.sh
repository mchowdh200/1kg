#!/bin/env bash

snakemake -s stix_1kg_dels.smk -j 32 --use-conda --conda-frontend mamba
