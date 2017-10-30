# AV16.3 - audiovisual

SEQ=(8 11 12)

almode=4;  # when det-> 3D GCF, otherwise-> 2D GCF
vlmode=2;   # det 
hmode='hsvspatio';  # hsvspatio
R=6;
N=100;
savFig=0;
savRst=1;

flag=0;
for sq in {0..2}
do
for cam in {1..3}
do 
nohup matlab -nodisplay -nojvm -nosplash -r "try myTracker3D_faceRP_3DGCF("${SEQ[$sq]}",'all',"$almode","$vlmode",'$hmode',"$R","$N","$flag",0,"$savFig","$savRst",'AV16.3',"$cam"); catch; disp('error'); end; quit" > sq${SEQ[$sq]}_vl${vlmode}_al${almode}_hl{$hmode}_cam${cam}_f${flag}.txt &
done
done 
wait



# FBK dataset
SEQfbk=(11 13 17 20)


almode=4;  # 2D+3D GCF
vlmode=2;  # det
hmode='hsvspatio';  # no histogram
flag=0;
for sq in {0..3}
do
nohup matlab -nodisplay -nojvm -nosplash -r "try myTracker3D_faceRP_3DGCF("${SEQfbk[$sq]}",'all',"$almode","$vlmode",'$hmode',"$R","$N","$flag",0,"$savFig","$savRst",'FBK',5); catch; disp('error'); end; quit" > sq${SEQfbk[$sq]}_FBK_vl${vlmode}_al${almode}_hl{$hmode}_f${flag}.txt &
done

flag=2;
for sq in {0..3}
do
nohup matlab -nodisplay -nojvm -nosplash -r "try myTracker3D_faceRP_3DGCF("${SEQfbk[$sq]}",'all',"$almode","$vlmode",'$hmode',"$R","$N","$flag",0,"$savFig","$savRst",'FBK',5); catch; disp('error'); end; quit" > sq${SEQfbk[$sq]}_FBK_vl${vlmode}_al${almode}_hl{$hmode}_f${flag}.txt &
done



flag=1;
almode=1;  # 3D GCF SSL resutls
vlmode=2;  # det
hmode='hsvspatio';  # no histogram
for sq in {0..3}
do
nohup matlab -nodisplay -nojvm -nosplash -r "try myTracker3D_faceRP_3DGCF("${SEQfbk[$sq]}",'all',"$almode","$vlmode",'$hmode',"$R","$N","$flag",0,"$savFig","$savRst",'FBK',5); catch; disp('error'); end; quit" > sq${SEQfbk[$sq]}_FBK_vl${vlmode}_al${almode}_hl{$hmode}_f${flag}.txt &
done
