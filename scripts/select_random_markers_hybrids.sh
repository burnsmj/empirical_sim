#!/bin/bash
#SBATCH --time=0:30:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem=80gb
#SBATCH -J select_random_markers
#SBATCH -o /home/hirschc1/della028/projects/genomic_prediction/hybrids/analysis/MSI_dump/%x_%j.out
#SBATCH -e /home/hirschc1/della028/projects/genomic_prediction/hybrids/analysis/MSI_dump/%x_%j.err
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=della028@umn.edu
#SBATCH --no-requeue

module load R/3.6.0

# go to project folder
cd ~/projects/genomic_prediction/hybrids

# filter hapmap
for marker in all sv snp snp_ld snp_not_ld; do
  # if data has SVs and SNPs, randomly sample equal numbers of SVs and SNPs
  [[ ${marker} == all ]] && options="--proportion-SV-SNP=0.5 --SVs-list=data/SVs_IDs_poly.txt" || options=""
  # create folder for output
  mkdir -p analysis/sim_traits_gwas/datasets/iter${ITER}
  # set input variables
  IN=analysis/sim_traits_gwas/datasets/usda_hybrids.${marker}_markers.hmp.txt
  OUT=analysis/sim_traits_gwas/datasets/iter${ITER}/usda_hybrids.${marker}_markers.adjusted-n-markers.hmp.txt
  OPT=${options}
  SEED=${SEED}
  # sample markers
  echo "iteration ${ITER} - marker ${marker} - seed ${SEED}"
  Rscript scripts/select_random_markers.R ${IN} ${OUT} ${NSAMPLE} ${OPT} --seed=${SEED}
  # make sure allele column is correct
  run_pipeline.pl -Xmx10g -importGuess analysis/sim_traits_gwas/datasets/iter${ITER}/usda_hybrids.${marker}_markers.adjusted-n-markers.hmp.txt \
                  -export analysis/sim_traits_gwas/datasets/iter${ITER}/usda_hybrids.${marker}_markers.adjusted-n-markers.hmp.txt \
                  -exportType HapmapDiploid
  # each dataset will have different seed number
  SEED=$((${SEED}+1))
done
