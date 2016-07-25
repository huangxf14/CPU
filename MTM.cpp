#include<iostream>
#include<fstream>
#include<string>
using namespace std;

struct label
{
	string name;
	int pos;
};//用于存储标签名和标签位置的结构体
char dict[16]={'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'};
label lab[2000];
string mips[30]={"nop","add","addu","sub","subu","and","or","xor","nor",
"sll","srl","sra","slt","jalr","jr","lw","sw","lui",
"addi","addiu","andi","slti","sltiu","beq","bne","blez",
"bgtz","bltz","j","jal"};
int numr=15,numi=28,label_num=0;
string reg [32]={"zero","at","v0","v1","a0","a1","a2","a3","t0","t1","t2","t3","t4","t5","t6","t7",
"s0","s1","s2","s3","s4","s5","s6","s7","t8","t9","k0","k1","gp","sp","fp","ra",};

ifstream mips_file("mips.txt",ios::in);
ofstream code_file("code.txt",ios::out),label_file("label.txt",ios::out); 
fstream temp_file;
string ins="",s="",ss="",rs="",rt="",rd="",funct="",shamt="",offset="",target="";
int now=0,ins_now=0;

bool useful(char x)//判断此字符否是数字或字母或负号，用于提取指令名、寄存器名、立即数、标签
{
	if ((x>=48)&&(x<=57)) return true;
	if ((x>=65)&&(x<=90)) return true;
    if ((x>=97)&&(x<=122)) return true;
	if (x=='-') return true;
	return false;
};

string change(string x)//将寄存器名转化为对应的五位二进制数
{
	string ans="00000";
	for (int i=0;i<32;++i)
	{
		if (x==reg[i])
		{
			int temp=i;
			for (int j=4;j>=0;--j)
			{
					if ((temp&1)==1) ans[j]='1';
					temp>>=1;
			};
			break;
		};
	};
	return ans;
};

void change_num2(string x)//将二进制机器码转化成十六进制数并输出到文件中
{
	int temp=0;
	for (int i=0;i<8;++i)
	{
		temp=0;
		for (int j=0;j<4;++j)
		{temp<<=1;temp+=x[i*4+j]-48;};
		code_file<<dict[temp];
	};
	code_file<<endl;
};

string change_num5(string x)//将十进制数（字符串形式）转化为五位二进制数
{
	int temp=0;
	for (int i=0;i<x.length();++i)
	{
		temp*=10;
		temp+=int(x[i])-48;
	};
	string ans="00000";
	for (int j=4;j>=0;--j)
	{
		if ((temp&1)==1) ans[j]='1';
		temp>>=1;
	};
	return ans;
};

string change_num16(string x)//将十进制数（字符串形式）转化为十六位二进制数
{
	int sign;
	if (x[0]=='-') sign=1;else sign=0;
	int temp=0;
	for (int i=sign;i<x.length();++i)
	{
		temp*=10;
		temp+=int(x[i])-48;
	};
	string ans="0000000000000000";
	for (int j=15;j>=0;--j)
	{
		if ((temp&1)==1) ans[j]='1';
		temp>>=1;
	};
	if (sign==1)
	{
		for (int i=0;i<16;++i) 
			if (ans[i]=='0') ans[i]='1';else ans[i]='0';
		int add=1;
		for (int i=15;i>=0;--i)
			if (add==1)
			{
				if (ans[i]=='0') ans[i]='1';else ans[i]='0';
				if (ans[i]=='0') add=1;else add=0;
			};
	};
	return ans;
};

string find_label(string s)//找到标签s的位置并计算和当前位置的差后转化为二进制数
{
	int flag=-1;
	for (int i=0;i<label_num;++i)
		if (lab[i].name==s) 
		{flag=lab[i].pos;break;};
	string ans="0000000000000000";
	if (flag==-1) {cout<<"Strange Label"<<s<<" at"<<ins_now<<endl;return ans;};
	int temp=flag-ins_now-1,sign=0;
	if (temp<0) {sign=1;temp=-temp;};
	for (int j=15;j>=0;--j)
	{
		if ((temp&1)==1) ans[j]='1';
		temp>>=1;
	};
	if (sign==1)
	{
		for (int i=0;i<16;++i) 
			if (ans[i]=='0') ans[i]='1';else ans[i]='0';
		int add=1;
		for (int i=15;i>=0;--i)
			if (add==1)
			{
				if (ans[i]=='0') ans[i]='1';else ans[i]='0';
				if (ans[i]=='0') add=1;else add=0;
			};
	};
	return ans;
};

string find_target(string s)//找到标签位置并计算转化为二进制数
{
	int flag=-1;
	for (int i=0;i<label_num;++i)
		if (lab[i].name==s) 
		{flag=lab[i].pos;break;};
	
	string ans="00000000000000000000000000";
	
	if (flag==-1) {cout<<"Strange Target"<<s<<" at"<<ins_now<<endl;return ans;};
	int temp=flag;
	for (int j=25;j>=0;--j)
	{
		if ((temp&1)==1) ans[j]='1';
		temp>>=1;
	};
	return ans;
};

int find()//确定一个指令属于哪一类型的指令，nop返回0，R型返回1，I型返回2，J型返回3，不合法返回-1
{
	for (int i=0;i<31;++i)
	{
		if (ss==mips[i])
		{
			if (i==0) return 0;
			if (i<numr) return 1;
			if (i<numi) return 2;
			return 3;
		};
	};
	return -1;

};

bool opr()//处理R型指令
{
	for (int i=0;i<6;++i) s+="0";
	funct="";rs="";rt="";rd="";shamt="00000";
	if (ss=="add") funct="100000";
	else if (ss=="addu") funct="100001";
	else if (ss=="sub") funct="100010";
	else if (ss=="subu") funct="100011";
	else if (ss=="and") funct="100100";
	else if (ss=="or") funct="100101";
	else if (ss=="xor") funct="100110";
	else if (ss=="nor") funct="100111";
	else if (ss=="sll") funct="000000";
	else if (ss=="srl") funct="000010";
	else if (ss=="sra") funct="000011";
	else if (ss=="slt") funct="101010";
	else if (ss=="jalr") funct="001001";	
	else if (ss=="jr") funct="001000";
	else {cout<<"Unable to translate "<<ins_now<<endl;return false;};
	if ((ss=="sll")||(ss=="srl")||(ss=="sra"))
	{
		rs="00000";
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rd+=ins[now++];
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rt+=ins[now++];
		shamt="";
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) shamt+=ins[now++];
		rd=change(rd);
		rt=change(rt);
		shamt=change_num5(shamt);
	}
	else if (ss=="jalr")
	{
		rt="00000";
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rs+=ins[now++];
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rd+=ins[now++];
		rd=change(rd);
		rs=change(rs);
	}
	else if (ss=="jr")
	{
		rt="00000";rd="00000";
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rs+=ins[now++];
		rs=change(rs);
	}
	else
	{
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rd+=ins[now++];
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rs+=ins[now++];
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rt+=ins[now++];
		rd=change(rd);
		rs=change(rs);
		rt=change(rt);
	};
	s=s+rs+rt+rd+shamt+funct;
	return true;
};

bool opi()//处理I型指令
{
	rs="";rt="";offset="";
	if ((ss=="lw")||(ss=="sw"))
	{
		if (ss=="lw") s="100011";
		else if (ss=="sw") s="101011";
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rt+=ins[now++];
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) offset+=ins[now++];
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rs+=ins[now++];
		rt=change(rt);
		rs=change(rs);
		offset=change_num16(offset);
		s=s+rs+rt+offset;
		return true;
	};
	if ((ss=="lui"))
	{
		s="001111";
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rt+=ins[now++];
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) offset+=ins[now++];
		rt=change(rt);
		rs="00000";
		offset=change_num16(offset);
		s=s+rs+rt+offset;
		return true;
	};
	if ((ss=="addi")|(ss=="andi")||(ss=="slti")||(ss=="sltiu"))
	{
		if (ss=="addi") s="001000";
		else if (ss=="andi") s="001100";
		else if (ss=="slti") s="001010";
		else if (ss=="sltiu") s="001101";
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rt+=ins[now++];
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rs+=ins[now++];
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) offset+=ins[now++];
		rt=change(rt);
		rs=change(rs);
		offset=change_num16(offset);
		s=s+rs+rt+offset;
		return true;
	};
	if ((ss=="beq")||(ss=="bne"))
	{
		if (ss=="beq") s="000100";
		else if (ss=="bne") s="000101";
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rs+=ins[now++];
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rt+=ins[now++];
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) offset+=ins[now++];
		rt=change(rt);
		rs=change(rs);
		offset=find_label(offset);
		s=s+rs+rt+offset;
		return true;
	};
	if ((ss=="blez")||(s=="bgtz")||(s=="bltz"))
	{
		if (ss=="blez") s="000110";
		else if (ss=="bgtz") s="000111";
		else if (ss=="bltz") s="000001";
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) rs+=ins[now++];
		while (!useful(ins[now])) ++now;
		while (useful(ins[now])) offset+=ins[now++];
		rt="00000";
		rs=change(rs);
		offset=find_label(offset);
		s=s+rs+rt+offset;
		return true;
	};
	cout<<"Unable to translate "<<now<<endl;
	return false;
};

bool opj()//处理J型指令
{
	target="";
	if (ss=="j") s="000010";
	else if (ss=="jal") s="000011";
	while (!useful(ins[now])) ++now;
	while (useful(ins[now])) target+=ins[now++];
	target=find_target(target);
	s=s+target;
	return true;
	
};

bool code()//提取指令名并判断指令类型，分类计算机器码
{
	now=0;
	s="";ss="";
	while (!useful(ins[now])) ++now;
	while (useful(ins[now])) {ss+=ins[now++];};
	int op=find();
	if (op==-1) return false;
	if (op==0) 
	{
		for (int i=0;i<32;++i) s+="0";
		return true;
	};
	if (op==1)
	{
		return opr();
	};
	if (op==2)
	{
		return opi();
	};
	if (op==3)
	{
		return opj();
	};
	return false;
};

bool empty()
{
	int flag=-1;
	for (int i=0;i<ins.length();++i)
		if (ins[i]=='#')
		{flag=i;break;};
	if (flag!=-1)
	{
		ins.erase(flag,ins.length()-flag);
	};
	for (int i=0;i<ins.length();++i)
		if (useful(ins[i])) return false;
	return true;
};

int main()
{
	now=-1;
	int flag=-1;
	temp_file.open("temp.txt",ios::out);
	//遍历提取标签
	while (mips_file.peek()!=EOF)
	{
		++now;
		if(getline(mips_file,ins))
		if (!empty())
		{
			flag=-1;
			for(int i=0;i<ins.length();++i)
				if (ins[i]==':') flag=i;
			if (flag!=-1)
			{
				lab[label_num].name="";
				for (int i=0;i<ins.length();++i)
				{
					if (useful(ins[i]))
						lab[label_num].name+=ins[i];
					if (ins[i]==':')
						break;
				};
				ins.erase(0,flag);
				lab[label_num].pos=now;
				label_file<<lab[label_num].name<<endl;
				++label_num;
			};
			if (empty()) --now;
			else
			{
				for (int i=0;i<ins.length();++i)
					if (useful(ins[i])) 
					{if (i!=0) ins.erase(0,i-1);break;};
				temp_file<<ins<<endl;
			};
		}
		else --now;
	};
	mips_file.close();
	temp_file.close();
	temp_file.open("temp.txt",ios::in);
	ins_now=-1;
	//计算并输出机器码
	while (temp_file.peek()!=EOF)
	{
		++ins_now;
		if(getline(temp_file,ins))
		{
			ins+=",";
			if (code())
				change_num2(s);
		};
	};
	temp_file.close();
	code_file.close();
};
