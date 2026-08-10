# BRPT Real-Time Results

Continuously updated computational results and interactive plots produced by **BRPT**.

**Authors:** Marco Righi and Michele Baldi

## Interactive results

The GitHub Pages site for this repository is intended to provide direct access to the latest validated BRPT plots:

`https://marcorighi.github.io/BRPT_real_time_results/`

The underlying plot index is:

`results_plots/index.html`

## Purpose of this repository

`BRPT_real_time_results` is a continuously updated public mirror of the latest BRPT computational state.

The repository is not intended to replace immutable archival releases. Its purpose is to expose the most recent validated computational results and their interactive visualizations while long-running BRPT computations continue.

Before publication, the computational snapshot is copied to a separate working area and all JSON files are parsed and validated. Plot generation is then performed using only the frozen copy. The validated snapshot is packaged as `results_no_csv.zip`, transferred to the machine maintaining this Git repository, validated again, and only then committed and pushed.

CSV files are intentionally excluded from the transferred real-time snapshot.

## Repository contents

The repository may contain the following result directories:

- `results_ring/` — ring-search computational state and summaries.
- `results_primes/` — prime-scan computational state and summaries.
- `results_c21/` — C21-related summaries and results.
- `results_psps/` — pseudoprime-related summaries and results.
- `results_galois/` — Galois classification, certificate, and density results when included in the current snapshot.
- `results_plots/` — generated static and interactive plots.

The main interactive entry point is:

`results_plots/index.html`

## Update pipeline

The publication workflow is:

1. BRPT continues its computations on the computational server.
2. A frozen copy of the current result directories is created.
3. Every JSON file in that copy is parsed to detect incomplete, truncated, or syntactically invalid files.
4. The source files are checked for concurrent modification while the snapshot is being created.
5. `brpt_test.py --mode PLOT` generates the plots using only the validated frozen copy.
6. The snapshot is packaged as `results_no_csv.zip`.
7. The ZIP archive is transferred to the machine maintaining this Git repository.
8. The transferred archive is tested and all JSON files are validated again.
9. Only a successfully validated snapshot is imported, committed, and pushed to GitHub.

This procedure is designed to prevent a partially written JSON file or an inconsistent file transfer from being published as the current result set.

## Reproducibility and archival status

The `main` branch represents the **latest available computational snapshot** and therefore changes over time.

For reproducible scientific citation, use immutable software releases and archived datasets, including the Zenodo records listed below.

## Related BRPT software

M. Righi and M. Baldi,  
**BRPT: cubic Frobenius probable-primality test**,  
version 1.0.1 [Software], Zenodo, 2026.  
DOI: [10.5281/zenodo.21848363](https://doi.org/10.5281/zenodo.21848363)

## Galois certificates and exact densities

M. Righi and M. Baldi,  
**BRPT Galois Certificates and Exact Chebotarev Densities for Search Rings 1–20**,  
[Data set], Zenodo, 2026.  
DOI: [10.5281/zenodo.21850749](https://doi.org/10.5281/zenodo.21850749)

## LaTeX references

```latex
\bibitem{BRPTv101}
M. Righi and M. Baldi,
\emph{BRPT: cubic Frobenius probable-primality test},
version 1.0.1 [Software], Zenodo, 2026.
DOI:
\href{https://doi.org/10.5281/zenodo.21848363}
{10.5281/zenodo.21848363}.

\bibitem{BRPTGalois2026}
M. Righi and M. Baldi,
\emph{BRPT Galois Certificates and Exact Chebotarev Densities for
Search Rings 1--20},
[Data set], Zenodo, 2026.
DOI:
\href{https://doi.org/10.5281/zenodo.21850749}
{10.5281/zenodo.21850749}.
```

## Notes

The plots in this repository are generated from the validated JSON state files. The repository should therefore be interpreted as a live computational reporting layer, while Zenodo records and tagged releases provide immutable research artifacts.

<!-- TEST update_BRPT -->
