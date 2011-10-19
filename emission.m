%Ryan Lawhon
%Emission spectra for first data set

tic

lambda_ruth=406:2:850;     %wavelength values for ruthenium emission
lambda_por=464:2:944;      %wavelength values for porphyrin emission
lambda_trans_ruth=572:648; %wavelength values for ruthenium filter
lambda_trans_por=664:739;  %wavelength values for porphyrin filter
lambda_trans_510=467:553;  %wavelength values for 510 filter
lambda_pmt=200:100:900;    %wavelength range for pmt components



emit_ruth=[0 %406          ruthenium emission spectrum values
    50
    100
    150
    200
    250 
    300
    350
    400
    450
    500
    525
    550
    575
    600
    625
    650
    675
    700
    725
    750
    775
    800 %450
    850 
    900
    950
    1000
    1050
    1100
    1150
    1200
    1250 
    1300
    1350
    1400
    1450
    1500
    1550
    1600 %482
    1620
    1626
    1630
    1638
    1640
    1650
    1655
    1670
    1680  %500
    1684
    1688
    1700
    1710.4
    1716.9
    1726.3
    1734.2
    1738.5
    1744.21
    1746.808   %520 %%%%
    1792.851
    1813.871
    1905.962
    1961.018
    2026.087
    2017.077
    2115.185
    2207.290
    2401.527
    2582.766 %540
    2990.367
    3246.790
    3727.677
    4093.433
    4630.672
    5241.265
    6257.350
    7288.035
    8620.626
    9858.655 %560
    11773.563
    13781.055
    15549.682
    17896.275
    20702.652
    23438.236
    26279.119
    29177.014
    32350.830
    35070.465 %580
    38365.207
    41096.391
    44404.480
    46937.164
    49359.250
    52377.223
    54706.273
    56483.973
    58643.684
    59941.063 %600
    61178.395
    62394.816
    63248.207
    63317.445
    64290.133
    63987.215
    64061.648
    63509.668
    63028.109
    62377.258
    61774.121
    60889.375
    59763.629
    58701.418
    57306.980
    56158.578
    54915.148
    54054.063
    52150.121
    51211.168
    50011.941
    48403.180
    47615.699
    45783.578
    44458.727
    43183.871
    41950.738
    40520.223
    39157.109
    37736.816
    36441.910
    35404.574
    34202.859
    32503.402
    31586.115
    30062.676
    29067.350
    27912.197
    26640.102
    25925.299
    24607.920
    23536.441
    22787.371
    22004.197
    21205.166
    20434.768
    19250.459
    18639.393
    17782.207
    16813.416 %700 %%%%
    16000
    15200
    14400
    13600
    12800
    11000
    10500
    9775
    9000
    8200  %720
    7500
    6800
    6000
    5800
    5200
    4900
    3800
    3300
    3000
    2820  %740
    2650
    2420
    2370
    2300
    2240
    2180
    2050
    2000
    1950
    1900 %760
    1850
    1800
    1750
    1700
    1650
    1600
    1550
    1500
    1450
    1400 %780
    1350
    1300
    1250
    1200
    1150
    1100
    1050
    1000
    950
    900 %800
    850
    825
    800
    775
    750
    725
    700
    675
    650
    625 %820
    600
    575
    550
    525
    500
    450
    400
    350
    300
    250 %840
    200
    150
    100
    50
    0]';  %850
    
    emit_por=[              %porphyrin emission spectrum values
           100
           200
           300 
           400 
           500 
           600
           700
           800
           900
           1000
           1030
           1060
           1100
           1140
           1170
           1200
           1230
           1251
           1271.428  %500
           1283.436
           1265.424
           1306.452
           1226.899
           1240.407  %510
           1178.368
           1164.859
           1174.866
           1159.856
           1169.863  %520
           1141.845
           1123.835
           1153.352
           1156.354
           1167.861  %530
           1163.859
           1187.373
           1200.882
           1195.879
           1192.877 %540
           1208.887
           1234.404
           1366.995
           1339.475
           1370.998 %550
           1364.994
           1457.062
           1399.519
           1461.566
           1421.035 %560
           1460.065
           1532.622
           1550.136
           1629.203
           1631.705 %570
           1652.723
           1761.322
           1750.311
           1816.374
           1827.384 %580
           1860.917
           1853.910
           1836.894
           1819.877
           1829.887 %590
           1820.878
           1830.387
           1824.882
           1815.373
           1911.468 %600
           1911.968
           2045.107
           2139.212
           2148.222
           2374.993 %610
           2435.070
           2499.154
           2299.400
           2280.877
           2144.217 %620
           2159.735
           2022.083
           1919.976
           1970.028
           1903.960 %630
           1876.432
           1888.444
           1804.863
           1901.457
           1907.464 %640
           1961.018
           2092.159
           2264.858
           2439.075
           2710.445 %650
           3037.442
           3443.638
           3873.971
           4418.164
           4998.107 %660
           5474.425
           6242.300
           7045.618
           7878.899
           8892.884 %670
           10090.876
           11330.870
           13046.373
           14796.177
           16615.178 %680
           18833.801
           20590.439
           22420.029
           24881.455
           26566.582 %690
           28504.912
           29980.389
           31186.592
           32208.947
           32766.363 %700
           33010.031
           33235.918
           33253.219
           32420.502
           31074.779 %710
           30664.691
           29266.881
           28009.111
           26744.049
           25164.148 %720
           23685.785
           22363.871
           20923.055
           19531.818
           18324.844 %730
           16615.178
           14796.177
           13046.373
           11330.870
           10090.876 %740
           8892.884
           7878.899  
           7045.618         
           6242.300         
           5474.425 %750         
           4998.107         
           4418.164  
           3873.971         
           3443.638         
           3037.442         
           2710.445 %762
           2439.075
           2264.858
           2092.159
           1961.018 %770
           1907.464
           1901.457
           1804.863
           1888.444
           1876.432 %780
           1903.960
           1970.028
           1919.976
           2022.083
           2159.735 %790
           2144.217
           2280.877 %794
           2299.400
           2499.154
           2435.070 %800
           1911
           1815
           1824
           1830
           1821
           1830
           1820
           1837
           1854
           1861 %820
           1827
           1816
           1750
           1761
           1753
           1632
           1629
           1550
           1533
           1460 %840
           1421
           1462
           1400
           1457
           1365
           1371
           1339
           1367
           1234
           1209 %860
           1193
           1196
           1201
           1187
           1164
           1168
           1156
           1153
           1124
           1142 %880
           1170
           1160
           1175
           1165
           1178
           1240
           1227
           1306
           1265
           1283 %900
           1271
           1212
           1151
           1090
           1031
           970
           910
           850
           790
           730 %920
           640
           580
           520
           460
           400
           340
           280
           220
           160
           100 %940
           40
           0]'; %944

       
   trans_ruth=[.0062               %ruthenium transmission filter values
              .05996
              .4363
              .7796
              .7368
              .7793
              .8287
              .8487
              .8573
              .8657
              .8749
              .8823
              .8862
              .8855
              .8809
              .8749
              .8703
              .8699
              .8735
              .879966
              .886
              .8898
              .8902
              .8886
              .8887
              .8883
              .88989
              .8912
              .8906
              .8876
              .88354
              .8804
              .8795
              .8811
              .8837
              .8864
              .8883
              .8892
              .8896
              .8898
              .89
              .89
              .8896
              .8878
              .8857
              .8839
              .8833
              .8839
              .8859
              .8882
              .88998
              .8904
              .889869987
              .88905
              .88767
              .888179
              .889185
              .889418
              .888069987
              .8835
              .8755
              .8639
              .8492
              .8323
              .816
              .8074
              .8132
              .8395
              .8641
              .8208
              .681
              .5535
              .5839
              .6205
              .1871
              .022
              0.004]';
          
    trans_por=[.001565            %porphyrin transmission filter values
              .0163
              .2442
              .608
              .5265
              .6622
              .8004
              .8379
              .8622
              .8892
              .8962
              .8923
              .8951
              .902
              .9009
              .8861
              .8674
              .8587
              .8666
              .8848
              .9011
              .9069
              .8987
              .8836
              .8724
              .8699
              .8769
              .89
              .9017
              .9085
              .9068
              .8993
              .8903
              .8839
              .8816
              .8848
              .8913
              .899
              .9053
              .9083
              .9079
              .9036
              .8981
              .8945
              .8932
              .8943
              .8981
              .9032
              .906312
              .9068
              .9047
              .9014
              .8992
              .8996
              .903
              .905
              .9028
              .8967
              .888
              .8826
              .8859
              .8948
              .8963
              .8755
              .833
              .7951
              .7897
              .8123
              .8044
              .7369
              .7258
              .6439
              .1993
              .0259
              0.0046
              0.00105]';
          
trans_510=[0.4184     %467            %510 filter transmission values
           8.291999   
           50.23
           58.69
           66.2199
           77.35
           77.86999
           79.01999
           82.54      %475
           83.91
           81.72
           78.97
           78.46
           80.73      %480
           84.06
           85.97
           85.75
           85.02
           85.49      %485
           87.24
           88.76
           88.48
           86.49
           84.45      %490
           84.04      
           85.58
           87.999
           89.65
           89.49      %495
           87.97      
           86.58
           86.33
           87.13
           87.9999      %500
           88.02
           86.91
           85.34
           84.5
           85.06        %505
           86.80      
           88.84      
           89.97
           89.62
           88.29      %510
           86.97      
           86.48      
           87.01
           88.01
           88.62     %515
           88.18      
           86.87     
           85.48
           84.76
           85.119998   %520
           86.30     
           87.63     
           88.38
           88.14
           87.21     %525
           86.05      
           85.30      
           85.14
           85.4
           85.72     %530
           85.8       
           85.46      
           84.76
           83.75
           82.74    %535
           82.05      
           82.09995  
           82.95
           84.10999
           83.91     %540
           80.84     
           75.33     
           70.22 
           68.25
           69.08      %545
           67.8      
           60.35      
           55.42
           58.86
           31.56    %550
           4.98       
           0.72       
           .014979999]';
       
trans_510=trans_510/100;       
                   
          
                  
pmt_values=[.125893    %200      first pmt component      
            .154882    %300 
            .147911    %400
            .131826    %500
            .117490    %600 
            .10        %700
            .050119    %800
            .0001]';   %900
        
pmt_values_2=[(10^(1.3)/100)   %200    %second pmt component
              (10^(1.6)/100)   %300
              (10^(1.78)/100)  %400
              (10^(1.8)/100)   %500
              (10^(1.7)/100)   %600
              (10^(1.48)/100)  %700
              (10^(1.32)/100)  %800
              (10^(-1.3)/100)]'; %900
      
  %**********************************************************************
  %Integrate each curve and divide the signal by the integral to obtain the
  %normalized curve (F_por and F_ruth)
  %**********************************************************************
  
  int_ruth=trapz(lambda_ruth,emit_ruth);
  int_por=trapz(lambda_por,emit_por);
  F_ruth=emit_ruth/int_ruth;
  F_por=emit_por/int_por;
  
  %**********************************************************************
  %Interpolate so pmt values for each are relative to the appropriate
  %lambda vector rather than the pmt vector
  %**********************************************************************
  
  pmt_values_ruth=interp1(lambda_pmt,pmt_values,lambda_ruth);
  pmt_values_ruth_2=interp1(lambda_pmt,pmt_values_2,lambda_ruth);
  
  pmt_values_ruth_filter=interp1(lambda_pmt,pmt_values,lambda_trans_ruth);
  pmt_values_ruth_filter_2=interp1(lambda_pmt,pmt_values_2,lambda_trans_ruth);
  
  pmt_values_por=interp1(lambda_pmt,pmt_values,lambda_por);
  pmt_values_por_2=interp1(lambda_pmt,pmt_values_2,lambda_por);
  
  pmt_values_por_filter=interp1(lambda_pmt,pmt_values,lambda_trans_por);
  pmt_values_por_filter_2=interp1(lambda_pmt,pmt_values_2,lambda_trans_por);
  
  pmt_values_510=interp1(lambda_pmt,pmt_values,lambda_trans_510);
  pmt_values_510_2=interp1(lambda_pmt,pmt_values_2,lambda_trans_510);
  
     for i=1:length(pmt_values_por)
      if(isnan(pmt_values_por(1,i)))
          pmt_values_por(1,i)=0;
      else pmt_values_por(1,i)=pmt_values_por(1,i);
      end
     end
    
       for i=1:length(pmt_values_por_2)
      if(isnan(pmt_values_por_2(1,i)))
          pmt_values_por_2(1,i)=0;
      else pmt_values_por_2(1,i)=pmt_values_por_2(1,i);
      end
       end

  %*********************************************************************
  %Interpolate the transmission filter vectors so they are also relative to
  %the original lambda vectors for each
  %*********************************************************************
  
  trans_new_ruth=interp1(lambda_trans_ruth,trans_ruth,lambda_ruth);
  trans_new_por=interp1(lambda_trans_por,trans_por,lambda_por);
  
  %**********************************************************************
  %Confirm that the integrals of the normalized curves do equal 1
  %**********************************************************************
  
  check_ruth=trapz(lambda_ruth,F_ruth);
  check_por=trapz(lambda_por,F_por);
  
  
  %**********************************************************************
  %Code to replace not a number values with zeros in the two transmission
  %filter vectors
  %**********************************************************************
  
    for i=1:length(trans_new_ruth)
      if(isnan(trans_new_ruth(1,i)))
          trans_new_ruth(1,i)=0;
      else trans_new_ruth(1,i)=trans_new_ruth(1,i);
      end
      
    end
  
    for i=1:length(trans_new_por)
      if(isnan(trans_new_por(1,i)))
          trans_new_por(1,i)=0;
      else trans_new_por(1,i)=trans_new_por(1,i);
      end
      
    end
    
  %**********************************************************************
  %Calculation of ruth and porphyrin values with filters only
  %**********************************************************************
  
  Int_ruth_1=trapz(lambda_ruth,F_ruth.*trans_new_ruth);
  Int_por_1=trapz(lambda_por,F_por.*(trans_new_por).^2);
  Ratio_1=Int_ruth_1/Int_por_1;
  
  %**********************************************************************
  %Calculation of ruth and porphyrin values with filters and one pmt
  %component (trans_new_por is squared because two filters used)
  %**********************************************************************
  
  Int_ruth_2=trapz(lambda_ruth,F_ruth.*trans_new_ruth.*pmt_values_ruth);
  Int_por_2=trapz(lambda_por,F_por.*(trans_new_por).^2.*pmt_values_por);
  Ratio_2=Int_ruth_2/Int_por_2;
  
  %**********************************************************************
  %Calculation of ruth and porphyrin values with filters and both pmt
  %components
  %**********************************************************************
  
  Int_ruth_3=trapz(lambda_ruth,F_ruth.*trans_new_ruth.*pmt_values_ruth.*pmt_values_ruth_2);
  Int_por_3=trapz(lambda_por,F_por.*(trans_new_por).^2.*pmt_values_por.*pmt_values_por_2);
  Ratio_3=Int_ruth_3/Int_por_3;
  
  %************************************************************************
  %Calculation of 510 filter values adding additional components
  %successively
  %************************************************************************
  
  Int_510_1=trapz(lambda_trans_510,trans_510);                                       %filter only
  Int_510_2=trapz(lambda_trans_510,trans_510.*pmt_values_510);                       %filter+1 pmt component
  Int_510_3=trapz(lambda_trans_510,trans_510.*pmt_values_510.*pmt_values_510_2)      %filter+ 2 pmt components
   
  %************************************************************************
  %Calculation of ruthenium and porphyrin filters + pmt components (i.e. no
  %normalized signal included in the analysis)
  %************************************************************************
  
  Int_ruth_filter_1=trapz(lambda_trans_ruth,trans_ruth);
  Int_ruth_filter_2=trapz(lambda_trans_ruth,trans_ruth.*pmt_values_ruth_filter);
  Int_ruth_filter_3=trapz(lambda_trans_ruth,trans_ruth.*pmt_values_ruth_filter.*pmt_values_ruth_filter_2)
  
  Int_por_filter_1=trapz(lambda_trans_por,(trans_por).^2);
  Int_por_filter_2=trapz(lambda_trans_por,(trans_por).^2.*pmt_values_por_filter);
  Int_por_filter_3=trapz(lambda_trans_por,(trans_por).^2.*pmt_values_por_filter.*pmt_values_por_filter_2)
  
%**************************************************************************
%Script to subtract reference values from porphyrin and ruthenium signals
%after averaging
%**************************************************************************

por_blank=daqread('Porph_Blank');
por_signal=daqread('Porph_Signal');
ruth_blank=daqread('Ruth_Blank');
ruth_signal=daqread('Ruth_Signal');
new_por_signal=mean(por_signal)-mean(por_blank);
new_ruth_signal=mean(ruth_signal)-mean(ruth_blank);

ratio_xsection=(Int_por_3/Int_ruth_3)*(new_ruth_signal(1,1)/new_por_signal(1,1))
toc     
%************************************************************************
%Ignore the following, as it is attempting to fit a curve to the original
%emission spectra for porphyrin and ruthenium and is indubitably of
%questionable interest at this point (unless you wish to learn the
%difference between a Wookiee and a Neimodean)
%************************************************************************
% 
%    syms wookiee;
%    Chewbacca=int((62105*exp(-((wookiee-612.5)^2)/(2*(38.0793)^2)))/(5.928e6)*(86.14),wookiee,570,650);
%    syms neimodean;
%    Gunray=int((32500*exp(-((neimodean-705)^2)/(2*(22.796)^2)))/(1.8571e6)*(88.8)^2,neimodean,665,740);
%   for k=1:1:length(lambdar)
%        final_ruth_3(k)=-3e-10*(lambdar(k))^(6) + 1e-6*(lambda(k))^(5) - 0.0017*(lambda(k))^(4) + 1.3522*(lambda(k))^(3) - 619.46*(lambda(k))^(2) + 151315*(lambda(k)) - 2e7;
%    end
%    figure(3);
%    plot(lambdar,final_ruth_3);
%

 

              
     
              
              
              
              
          
          
          
          
          
          
 

 



