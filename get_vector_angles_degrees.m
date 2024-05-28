function [ds_unit_angles,ds_within_angles,unit_angles,within_angles] = get_vector_angles_degrees(outcomes,ds_events)

sunit_angles=[];
swithin_angles=[];

punit_angles=[];
pwithin_angles=[];

eunit_angles=[];
ewithin_angles=[];
peunit_angles=[];
pewithin_angles=[];
seunit_angles=[];
sewithin_angles=[];


ds_unit_angles=nan(5,12);
ds_within_angles=nan(5,12);
unit_angles=cell(3,12);
within_angles=cell(3,12);

for d = 1: length(ds_events)
    som_vects=outcomes(d).som_binned_vect;
    pv_vects=outcomes(d).pv_binned_vect;
    ex_vects=outcomes(d).ex_binned_vect; 
    u_vect=ones(size(som_vects,1),1);
    ex_type=outcomes(d).ex_type;
    
  
    for s = 1:size(som_vects,2)
        CosTheta = max(min(dot(som_vects(:,s),u_vect)/(norm(som_vects(:,s))*norm(u_vect)),1),-1);
        angle = real(acosd(CosTheta));
        sunit_angles=[sunit_angles,angle];

        for s2=1:size(som_vects,2)
            if s2~=s
                CosTheta = max(min(dot(som_vects(:,s),som_vects(:,s2))/(norm(som_vects(:,s))*norm(som_vects(:,s2))),1),-1);
                angle = real(acosd(CosTheta));
                swithin_angles=[swithin_angles,angle];
            end
        end
    end

    for e = 1:size(ex_vects,2)
      CosTheta = max(min(dot(ex_vects(:,e),u_vect)/(norm(ex_vects(:,e))*norm(u_vect)),1),-1);
       angle = real(acosd(CosTheta));
       eunit_angles=[eunit_angles,angle];
        
       for e2=1:size(ex_vects,2)
          if e2~=e
                CosTheta = max(min(dot(ex_vects(:,e),ex_vects(:,e2))/(norm(ex_vects(:,e))*norm(ex_vects(:,e2))),1),-1);
                angle = real(acosd(CosTheta));
                ewithin_angles=[ewithin_angles,angle];
            end
        end
    end
    
    % -- calculate within SOM 
    somex_vects=ex_vects(:,ex_type==1);
    
    for e = 1:size(somex_vects,2)
        %--- calcluate alltogether 
        seunit_angles=[seunit_angles,cosineSimilarity(somex_vects(:,e)',u_vect')];
        %sunit_angles = [sunit_angles,acosd(dot(som_vects(:,s),u_vect)./(norm(som_vects(:,s))*norm(u_vect)))];         

        for e2=1:size(somex_vects,2)
            if e2~=e
                sewithin_angles=[sewithin_angles,cosineSimilarity(somex_vects(:,e)',somex_vects(:,e2)')];     
            end
        end    
    end
    
    pvex_vects=ex_vects(:,ex_type==2); 
     for e = 1:size(pvex_vects,2)
        %--- calcluate alltogether 
        peunit_angles=[peunit_angles,cosineSimilarity(pvex_vects(:,e)',u_vect')];
        %sunit_angles = [sunit_angles,acosd(dot(som_vects(:,s),u_vect)./(norm(som_vects(:,s))*norm(u_vect)))];         

        for e2=1:size(pvex_vects,2)
            if e2~=e
                pewithin_angles=[pewithin_angles,cosineSimilarity(pvex_vects(:,e)',pvex_vects(:,e2)')];     
            end
        end    
    end

    for e = 1:size(pv_vects,2)
       CosTheta = max(min(dot(pv_vects(:,e),u_vect)/(norm(pv_vects(:,e))*norm(u_vect)),1),-1);
       angle = real(acosd(CosTheta));
       punit_angles=[punit_angles,angle];
        
       for e2=1:size(pv_vects,2)
          if e2~=e
                CosTheta = max(min(dot(pv_vects(:,e),pv_vects(:,e2))/(norm(pv_vects(:,e))*norm(pv_vects(:,e2))),1),-1);
                angle = real(acosd(CosTheta));
                pwithin_angles=[pwithin_angles,angle];
            end
        end
    end
    
    ds_unit_angles(1,d)=mean(sunit_angles);
    ds_unit_angles(2,d)=mean(punit_angles);
    ds_unit_angles(3,d)=mean(eunit_angles); 
    %ds_unit_angles(4,d)=mean(seunit_angles);
    %ds_unit_angles(5,d)=mean(peunit_angles); 

    unit_angles{1,d}=sunit_angles;
    unit_angles{2,d}=punit_angles;
    unit_angles{3,d}=eunit_angles;

    ds_within_angles(1,d)=mean(swithin_angles);
    ds_within_angles(2,d)=mean(pwithin_angles);
    ds_within_angles(3,d)=mean(ewithin_angles);
    %ds_within_angles(4,d)=mean(sewithin_angles); 
    %ds_within_angles(5,d)=mean(pewithin_angles); 

    within_angles{1,d}=swithin_angles;
    within_angles{2,d}=pwithin_angles;
    within_angles{3,d}=ewithin_angles;
end