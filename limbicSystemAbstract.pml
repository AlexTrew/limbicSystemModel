
#define p (usingCoreOut==1)
#define q (usingRand==1)


int precision = 100; //precision indicates how many decimal places are used to represent 1

//eg if precision = 1000,
//1000 = 1
//100 = 0.1
//10 = 0.01
//1 = 0.001


//grid components

mtype = {seeLG,seeDG,seeNothing,seeBoth,rewardObject,noRewardObject,areaLG,areaDG,agent,nothing}

//
int grid[7] = {rewardObject,areaLG,nothing,nothing,nothing,areaDG,noRewardObject};


int agentPos //position of agent 

byte rewardLocation=0;//unused

//limbic system components

int RMTg
int VTA
int VTABase = precision/10; //VTA baseline
int reward
int OFC
int OFCLG
int OFCDG
int DRN
int lShell
int lShellLG
int lShellDG
int plasticity
int dlVP

int step;
int stepactual;

int coreLGOut; //output telling agent to head towards LG
int coreDGOut;//output telling agent to head towards DG

int coreWeightLG2LG //agent sees areaLG and decides to head towards areaLG
int coreWeightLG2DG //agent sees areaLG and decides to head towards areaDG
int coreWeightDG2LG //agent sees areaDG and decides to head towards areaLG
int coreWeightDG2DG //agent sees areaDG and decides to head towards areaDG

int SIF = 100*precision//shunting inibition factor

int placeFieldLG //set to 1*precision when agent is in areaLG
int placeFieldDG //set to 1*precision when agent is in areaDG



byte vision; //variable determining what the agent can see when exploring the grid


//int mPFCLG
//int mPFCDG

int c

int visualRewardDG 
int visualRewardLG


int visualDirectionLG
int visualDirectionDG

//property variables

bit usingCoreOut
bit usingRand



inline multiply(x,y,out)// x * y, out is answer
{
	out = x*y;
	out=out/precision;
	
	
	
}
inline divide(x,y,out)// x / y, out is answer
{	
	
	out = (x*precision)/y	
}

inline limit() //prevent underflow/overflow of array
{
if
::(agentPos>6)->agentPos=6
::(agentPos<0)->agentPos=0
::else->skip
fi
}


inline randomExplore() //randomly explore the grid
{
if
::vision=seeNothing
::vision=seeBoth
::vision=seeLG
::vision=seeDG
fi
if
::agentPos=agentPos-1;
::agentPos=agentPos+1;
::skip;
fi
usingCoreOut=0;
usingRand=1;
limit()
}



inline moveAgent() //intentional movement of agent as determined by limbic system calculations
{
if
::(grid[agentPos]!=areaLG || grid[agentPos]!=areaDG)->
	if
	::(coreLGOut>coreDGOut)->agentPos=agentPos-1;vision=seeLG
	::(coreDGOut>coreLGOut)->agentPos=agentPos+1;vision=seeDG
	fi
fi
usingCoreOut=1;
usingRand=0;

limit()
}

inline distanceCalc() //calculate distance of agent from placeFields LG and DG
{
if
::vision==seeLG->
	visualDirectionDG=0;
	if
	::(agentPos==2)->visualDirectionLG=1*precision;
	::(agentPos==3)->visualDirectionLG=2*precision;
	::(agentPos==4)->visualDirectionLG=3*precision;
	::else->skip
	fi
::vision==seeDG->
	visualDirectionLG=0; 
	if
	::(agentPos==2)->visualDirectionDG=3*precision;
	::(agentPos==3)->visualDirectionDG=2*precision;
	::(agentPos==4)->visualDirectionDG=1*precision;
	::else->skip
	fi
::vision==seeBoth->
	if
	::(agentPos==2)->visualDirectionDG=3*precision;visualDirectionLG=1*precision;
	::(agentPos==3)->visualDirectionDG=2*precision;visualDirectionLG=2*precision;
	::(agentPos==4)->visualDirectionDG=1*precision;visualDirectionLG=3*precision;
	::else->skip
	fi
::else->skip;
fi
}

inline seeReward(){ //determine whether the agent sees the reward when in a placefield
	if
	::(grid[agentPos]==areaLG && grid[0]==rewardObject)->visualRewardLG=precision
	::(grid[agentPos]==areaDG && grid[6]==rewardObject)->visualRewardDG=precision
	::else->visualRewardLG=0;visualRewardDG=0;
	fi
}

inline reset()//reset grid position when agent gets reward
{
if
::(grid[agentPos]==rewardObject)->agentPos=4;reward=precision;vision=seeBoth;reward=0;
::else->skip
fi
}

inline weightChange(w,d)//change the weight of a given node. This weight determines intentional behaviour of the agent
{
	w=w+d;
	if
	::(w>precision)->w=precision
	::(w<0)->w=0
	::(w>=0 && w<=precision)->skip
	fi
}

inline switchReward()//randomly swap location of reward and fake reward 
{
if
::(step==1000)->
	if
	::(grid[0]==rewardObject)->grid[0]=noRewardObject;grid[6]=rewardObject;c=c+1;
	::(grid[0]==noRewardObject)->grid[6]=noRewardObject;grid[0]=rewardObject;c=c+1;
	fi
	step=0;
::(c==3)->goto end;
::else->skip
fi


}

inline getReward()//get reward if in green area with reward
{
if
::(agentPos==5 && grid[agentPos+1]==rewardObject)->agentPos=agentPos+1
::(agentPos==1 && grid[agentPos-1]==rewardObject)->agentPos=agentPos-1
::else->skip
fi
}

inline setPlaceField()//set respective placefield to 1 when in the placefield
{
if
::(agentPos>=5)->placeFieldDG=precision;vision=seeDG;
::(agentPos<=1)->placeFieldLG=precision;vision=seeLG;
::else->placeFieldLG=0;placeFieldDG=0;
fi
}


proctype doStep() //run the limbic system
{
do
::



//VTA = (reward + VTAbase) / (1+ RMTg * SIF)
int RMTgxSIF;
multiply(RMTg,SIF,RMTgxSIF);
divide((reward+VTABase),precision+RMTgxSIF,VTA);

//OFC=OFCLG*placeFieldLG + OFCDG*placeFieldDG;
int OFCLGxplaceFieldLG;
int OFCDGxplaceFieldDG;
multiply(OFCLG,placeFieldLG,OFCLGxplaceFieldLG);
multiply(OFCDG,placeFieldDG,OFCDGxplaceFieldDG);

OFC = OFCLGxplaceFieldLG + OFCDGxplaceFieldDG;


//weight changes for OFC

int DRNxplaceFieldLG;
int DRNxplaceFieldDG;

//change OFCLG/DG by DRN*placefieldLG/DG
multiply(DRN,placeFieldLG,DRNxplaceFieldLG);
multiply(DRN,placeFieldDG,DRNxplaceFieldDG);
weightChange(OFCLG,DRNxplaceFieldLG);
weightChange(OFCDG,DRNxplaceFieldDG);


DRN=reward+OFC;

//lShell=placeFieldLG*lShellLG + placeFieldDG*lShellDG;
int placeFieldLGxlShellLG;
int placeFieldDGxlShellDG ;

multiply(placeFieldLG,lShellLG,placeFieldLGxlShellLG);
multiply(placeFieldDG,lShellDG,placeFieldDGxlShellDG);

lShell = placeFieldLGxlShellLG + placeFieldDGxlShellDG;


plasticity=VTA-VTABase/2;

if
::(plasticity<0)->plasticity=0;
::else->skip;
fi

//weightchanges for lshellLG/DG
int plasticityxplaceFieldLG;
int plasticityxplaceFieldDG;

multiply(plasticity,placeFieldLG,plasticityxplaceFieldLG);
multiply(plasticity,placeFieldDG,plasticityxplaceFieldDG);
weightChange(lShellLG,plasticityxplaceFieldLG);
weightChange(lShellDG,plasticityxplaceFieldDG);



//dlVP = 1/(1+lShell * SIF)
int lShellxSIF;
multiply(lShell,SIF, lShellxSIF);
divide(precision,precision+lShellxSIF,dlVP);


//RMTg = LHb = EP = 1/(dlVP * SIF);
int dlVPxSIF;
multiply(dlVP,SIF, dlVPxSIF);
divide(precision,precision+dlVPxSIF,RMTg);

//get core outputs

coreLGOut = (coreWeightLG2LG + coreWeightDG2LG + visualRewardLG);
coreDGOut = (coreWeightDG2DG + coreWeightLG2DG + visualRewardDG);	
//weight changes

int plasticityxVisualDirLG;
int plasticityxVisualDirLGxcoreLGOut;
int plasticityxVisualDirLGxcoreDGOut;
int plasticityxVisualDirDG;
int plasticityxVisualDirDGxcoreLGOut;
int plasticityxVisualDirDGxcoreDGOut;

multiply(plasticity,visualDirectionLG,plasticityxVisualDirLG); //
multiply(plasticityxVisualDirLG,coreLGOut,plasticityxVisualDirLGxcoreLGOut);
multiply(plasticityxVisualDirLG,coreDGOut,plasticityxVisualDirLGxcoreDGOut);

multiply(plasticity,visualDirectionDG,plasticityxVisualDirDG);
multiply(plasticityxVisualDirDG,coreLGOut,plasticityxVisualDirDGxcoreLGOut);
multiply(plasticityxVisualDirDG,coreDGOut,plasticityxVisualDirDGxcoreDGOut);

weightChange(coreWeightLG2LG,plasticityxVisualDirLGxcoreLGOut); //change coreWeightLG2LG by plasticity * visualDirectionLG * CoreLGOut;
weightChange(coreWeightLG2DG,plasticityxVisualDirLGxcoreDGOut); //change coreWeightLG2DG by plasticity * visualDirectionLG * CoreLGOut;
weightChange(coreWeightDG2LG,plasticityxVisualDirDGxcoreLGOut);//change coreWeightDG2LG by plasticity * visualDirectionLG * CoreLGOut;
weightChange(coreWeightDG2LG,plasticityxVisualDirDGxcoreDGOut);//change coreWeightDG2DG by plasticity * visualDirectionLG * CoreLGOut;

if
::(coreLGOut<precision/10 && coreDGOut<precision/10)->randomExplore();
::else->moveAgent();
fi

//inhibition on output. allows agent to "unlearn" 
divide(coreLGOut,precision+DRN,coreLGOut);
divide(coreDGOut,precision+DRN,coreDGOut);




setPlaceField();
switchReward();
reset();
distanceCalc();
seeReward();
getReward();

step=step+1;
stepactual=stepactual+1
od
end:
}	




init{
run doStep();
}
///issues



ltl verifyp{[](p -> <>q)}
	

	
