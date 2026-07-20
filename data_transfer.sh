#!/bin/bash
#PBS -N SSH2        # Job Name
#PBS -l nodes=1:ppn=1
#PBS -l walltime=24:00:00
#PBS -q q_qnlm_public
#PBS -V
#PBS -S /bin/bash 

inp_path='/home/wanghong/yhchen/B.E.13.BHISTC5.ne120_t12.sehires38.003.sunway/ocn/daily/'
inp_files=`ls ${inp_path}*.nc`
out_path='/home/jingzhao/yzb/daily/his/SSH_'
out_path1='/home/jingzhao/yzb/daily/his/SST_'
map=/home/hires_pi_ctrl/map_tx0.1v2_to_01x01d_bilin_da_130925.nc

i=0
for file in ${inp_files}
do 
    filelist[$i]=${file}
 i=$(($i+1))
done

for ((i=0;i<=119;i++))
do
    file=${filelist[i]}
    echo $file
 count=$(($count+1))

ncremap -v SSH -m $map -i ${file} -o ${out_path}${file:3-16:7}.nc
ncremap -v SST -m $map -i ${file} -o ${out_path1}${file:3-16:7}.nc
done 
