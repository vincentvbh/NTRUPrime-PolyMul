
DIR=obj/
out=benchmarks.log
echo -e "\t\t    Table 5\t\t" |tee $out
echo -e "\t Good's Trick\t   Mixed Radix1\t   Mixed Radix2" |tee -a $out

for i in ntrulpr761  
do
  sed -n 's/^NTT cycles: /NTT    :    /p' $DIR$i\_gs\_speed.bin.log |tr '\n' '\t' 
  sed -n 's/^NTT cycles: /|    /p' $DIR$i\_mr\_speed.bin.log |tr '\n' '\t'
  sed -n 's/^NTT cycles: /|    /p' $DIR$i\_mr1\_speed.bin.log
  sed -n 's/^NTT1s cycles: /NTT1s  :    /p' $DIR$i\_gs\_speed.bin.log |tr '\n' '\t'
  sed -n 's/^NTT1s cycles: /|    /p' $DIR$i\_mr\_speed.bin.log |tr '\n' '\t'
  sed -n 's/^NTT1s cycles: /|    /p' $DIR$i\_mr1\_speed.bin.log
  sed -n 's/^Base mul cycles: /Basemul:    /p' $DIR$i\_gs\_speed.bin.log |tr '\n' '\t'
  sed -n 's/^Base mul cycles: /|    /p' $DIR$i\_mr\_speed.bin.log |tr '\n' '\t'
  sed -n 's/^Base mul cycles: /|    /p' $DIR$i\_mr1\_speed.bin.log
  sed -n 's/^invNTT cycles: /invNTT :    /p' $DIR$i\_gs\_speed.bin.log |tr '\n' '\t'
  sed -n 's/^invNTT cycles: /|    /p' $DIR$i\_mr\_speed.bin.log |tr '\n' '\t'
  sed -n 's/^invNTT cycles: /|    /p' $DIR$i\_mr1\_speed.bin.log
  sed -n 's/^Poly mul cycles: /Polymul:   /p' $DIR$i\_gs\_speed.bin.log |tr '\n' '\t'
  sed -n 's/^Poly mul cycles: /|   /p' $DIR$i\_mr\_speed.bin.log |tr '\n' '\t'
  sed -n 's/^Poly mul cycles: /|   /p' $DIR$i\_mr1\_speed.bin.log



  echo ''
done | tee -a $out
echo -e "\n\n\t\t    Table 6\t\t" |tee -a $out
echo -e "   Good's Trick\t  Mixed Radix1 \t  Mixed Radix2" |tee -a $out

for i in ntrulpr761  
do
  echo -e "\t\t    Speed\t\t" 
  sed -n 's/keypair cycles: /G:     /p' $DIR$i\_gs\_speed.bin.log |tr '\n' '\t'
  sed -n 's/keypair cycles: /|     /p' $DIR$i\_mr\_speed.bin.log |tr '\n' '\t'
  sed -n 's/keypair cycles: /|     /p' $DIR$i\_mr1\_speed.bin.log
  sed -n 's/encaps cycles: /E:    /p' $DIR$i\_gs\_speed.bin.log |tr '\n' '\t'
  sed -n 's/encaps cycles: /|    /p' $DIR$i\_mr\_speed.bin.log |tr '\n' '\t'
  sed -n 's/encaps cycles: /|    /p' $DIR$i\_mr1\_speed.bin.log
  sed -n 's/decaps cycles: /D:    /p' $DIR$i\_gs\_speed.bin.log |tr '\n' '\t'
  sed -n 's/decaps cycles: /|    /p' $DIR$i\_mr\_speed.bin.log |tr '\n' '\t'
  sed -n 's/decaps cycles: /|    /p' $DIR$i\_mr1\_speed.bin.log

  echo -e "\t\t    Memory\t\t" 
  sed -n 's/key gen stack usage: /G:      /p' $DIR$i\_gs\_stack.bin.log |tr '\n' '\t'
  sed -n 's/key gen stack usage: /|      /p' $DIR$i\_mr\_stack.bin.log |tr '\n' '\t'
  sed -n 's/key gen stack usage: /|      /p' $DIR$i\_mr1\_stack.bin.log
  sed -n 's/encaps stack usage: /E:      /p' $DIR$i\_gs\_stack.bin.log |tr '\n' '\t'
  sed -n 's/encaps stack usage: /|      /p' $DIR$i\_mr\_stack.bin.log |tr '\n' '\t'
  sed -n 's/encaps stack usage: /|      /p' $DIR$i\_mr1\_stack.bin.log
  sed -n 's/decaps stack usage: /D:      /p' $DIR$i\_gs\_stack.bin.log |tr '\n' '\t'
  sed -n 's/decaps stack usage: /|      /p' $DIR$i\_mr\_stack.bin.log |tr '\n' '\t'
  sed -n 's/decaps stack usage: /|      /p' $DIR$i\_mr1\_stack.bin.log


  echo ''
done | tee -a $out

for i in sntrup761 
do
  echo -e "\t\t    Speed\t\t" 
  sed -n 's/keypair cycles: /G:   /p' $DIR$i\_gs\_speed.bin.log |tr '\n' '\t'
  sed -n 's/keypair cycles: /|   /p' $DIR$i\_mr\_speed.bin.log |tr '\n' '\t'
  sed -n 's/keypair cycles: /|   /p' $DIR$i\_mr1\_speed.bin.log
  sed -n 's/encaps cycles: /E:     /p' $DIR$i\_gs\_speed.bin.log |tr '\n' '\t'
  sed -n 's/encaps cycles: /|     /p' $DIR$i\_mr\_speed.bin.log |tr '\n' '\t'
  sed -n 's/encaps cycles: /|     /p' $DIR$i\_mr1\_speed.bin.log
  sed -n 's/decaps cycles: /D:     /p' $DIR$i\_gs\_speed.bin.log |tr '\n' '\t'
  sed -n 's/decaps cycles: /|     /p' $DIR$i\_mr\_speed.bin.log |tr '\n' '\t'
  sed -n 's/decaps cycles: /|     /p' $DIR$i\_mr1\_speed.bin.log

  echo -e "\t\t    Memory\t\t" 
  sed -n 's/key gen stack usage: /G:      /p' $DIR$i\_gs\_stack.bin.log |tr '\n' '\t'
  sed -n 's/key gen stack usage: /|      /p' $DIR$i\_mr\_stack.bin.log |tr '\n' '\t'
  sed -n 's/key gen stack usage: /|      /p' $DIR$i\_mr1\_stack.bin.log
  sed -n 's/encaps stack usage: /E:      /p' $DIR$i\_gs\_stack.bin.log |tr '\n' '\t'
  sed -n 's/encaps stack usage: /|      /p' $DIR$i\_mr\_stack.bin.log |tr '\n' '\t'
  sed -n 's/encaps stack usage: /|      /p' $DIR$i\_mr1\_stack.bin.log
  sed -n 's/decaps stack usage: /D:      /p' $DIR$i\_gs\_stack.bin.log |tr '\n' '\t'
  sed -n 's/decaps stack usage: /|      /p' $DIR$i\_mr\_stack.bin.log |tr '\n' '\t'
  sed -n 's/decaps stack usage: /|      /p' $DIR$i\_mr1\_stack.bin.log


  echo ''
done | tee -a $out
