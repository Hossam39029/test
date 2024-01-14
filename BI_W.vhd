------------------------------------------------------------------------------------
---- Company: 
---- Engineer: 
---- BI_W
---- Create Date:    05:18:58 10/13/2020 
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--use ieee.std_logic_unsigned.all;
--use IEEE.NUMERIC_STD.ALL;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:58:38 04/03/2018 
-- Design Name: 
-- Module Name:    BI - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;


entity BI_W is
port (
	Kitclk 		: in std_logic    			:='0';
	OneM			: in std_logic    			:='0';
	Qv				: in std_logic 				:='0';
	Ro				: in std_logic 				:='0';
	Hits        : in std_logic_vector(7 downto 0);
	Miss        : in std_logic_vector(7 downto 0);
    BI_Hits        : OUT std_logic_vector(7 downto 0);
    BI_Miss        : OUT std_logic_vector(7 downto 0);
	history_in	: in std_logic 				:='0';
	history_out	: out std_logic 				:='0';
	RBINS			: in std_logic_vector(11 downto 0);
	Ram_ADD			: out std_logic_vector(11 downto 0);
	ACPC			: in std_logic_vector(15 downto 0);
	Hitsin		: in std_logic_vector(7 downto 0);
	Missin		: in std_logic_vector(7 downto 0);
	Hitsout		:out std_logic_vector(7 downto 0);
	Missout		:out std_logic_vector(7 downto 0);
	PID_Scope		:out std_logic_vector(7 downto 0);
	WE				:out std_logic 				:='0';
	Ramclk		:out std_logic 				:='0';
	Trig			:out std_logic 				:='0';
	Rngout		:out std_logic_vector(15 downto 0);
	Azmout		:out std_logic_vector(15 downto 0);
	Extend		:out std_logic_vector(7 downto 0));
end BI_W;

architecture Behavioral of BI_W is
signal PID: integer range 0 to 18 :=0;
signal   Miss_S,Hits_S   : std_logic_vector (7 downto 0) ;-- range 0 to 3200000 :=0;
SIGNAL ONEM_S :STD_LOGIC;
begin
PROCESS(kitclk)
BEGIN
IF RISING_EDGE (kitclk) THEN 
ONEM_S<=oneM;
PID_Scope<=std_LOGIC_vector (to_unsigned(PID,8));
END IF;

END PROCESS;	

process(ONEM_S,kitclk,Ro,RBINS,QV,Hitsin,Missin)

begin
if falling_edge (kitclk)then 
	case PID is
		when 0 =>
			if Ro ='1' then 
			PID<=1;
			end if;
		when 1 =>
			if Ro ='0' then 
				Missout<="00000000";
				Hitsout<="00000000";
				history_out<='0';
				WE <='1';
				Ramclk<= not(ONEM_S);
				PID<=2;
			end if;
		when 2 =>
				WE <='1';
				Ramclk<= not(ONEM_S);
			if Ro ='1' then 
				WE<='0';
				Ramclk<='0';
				PID <=3;
			end if;
		when 3 =>
			if (ONEM_S='0')  then
			Ram_ADD<=RBINS;
			Trig<='0';

			PID <=4;
			end if;
		when 4 =>
			WE<='0';
--		if 	RBINS <= "001111101000" then
--			Miss_S <=Miss;
--            Hits_S <=Hits;			
--		   PID<=5;	
--		elsif RBINS > "001111101000" and RBINS < "011111010000" then
--		   	Miss_S <= Miss+"00000011";
--            Hits_S <=Hits-"00000011";
--			PID<=5;
--		elsif RBINS >= "011111010000"  then
--           Miss_S <=Miss+"00000101";
--           Hits_S <=Hits-"00000101";			
--			PID<=5;
--		else
            Miss_S <=Miss;
            Hits_S <=Hits;            
            PID<=5;		
--			end if;
		when 5 =>
		    BI_Hits<=Hits_S;
		    BI_Miss<=Miss_S;
		    
			Ramclk <='1';
			PID<=6;
		when 6 =>
			Ramclk <='0';
			PID<=17;
		when 7 =>
			if QV ='1'  and RBINS >"000111100000" and history_in ='1' then --and Missin > "000" then 
				Hitsout<=Hitsin+"00000001"; -- +2
				Missout<=Missin;	
				history_out<='1';
				PID<=10;
--			elsif QV ='1'  and RBINS >"0000000000001100" and history_in ='1' and Missin = "000" then 
--				Hitsout<=Hitsin+"00000010";
--				Missout<=Missin;	
--				history_out<='1';
--				PID<=11;
--			elsif QV ='1'  and RBINS >"0000000000001100" and history_in ='0' and Missin > "000"  then
--				Hitsout<=Hitsin+"00000001";
--				Missout<=Missin-"001";
--				history_out<='0';
--				PID<=11;
			elsif QV ='1'  and RBINS >"000111100000" and history_in ='0' then --and Missin = "000"  then
				Hitsout<=Hitsin+"00000001";
				Missout<=Missin;
				history_out<='1';
				PID<=10;
			else
				PID<=8;
			end if;
		when 8 =>
            if Hitsin ="00000000" then
                Hitsout<="00000000";
                Missout<="00000000";
                history_out<='0';
                PID<=10;
            elsif Hitsin > "00000000" and Hitsin < Hits_S and Missin < Miss_S and history_in ='1' then  --"00000101"
                Missout<=Missin+"00000001";
                Hitsout<=Hitsin;
                history_out<='0';
                PID<=10;
            elsif Hitsin > "00000000" and Hitsin < Hits_S and Missin < Miss_S and history_in ='0' then  --"00000101"
                    Missout<=Missin+"00000001";-- +2
                    Hitsout<=Hitsin;
                    history_out<='0';
                    PID<=10;
            elsif Hitsin > "00000000" and Hitsin >= Hits_S and Missin < Miss_S and history_in ='1'  then --"00000101"
                Missout<=Missin+"00000001";
                Hitsout<=Hitsin;
                history_out<='0';
                PID<=10;
            elsif Hitsin > "00000000" and Hitsin >= Hits_S and Missin < Miss_S and history_in ='0'  then --"00000101"
                Missout<=Missin+"00000001"; -- +2
                Hitsout<=Hitsin;
                history_out<='0';
                PID<=10;
            elsif Hitsin > "00000000" and Hitsin < Hits_S and Missin >= Miss_S then --"00000110"
                Missout<="00000000";
                Hitsout<="00000000";
                history_out<='0';
                PID<=10;
            elsif Hitsin > "00000000" and Hitsin >= Hits_S and Missin >= Miss_S then -- "00000110"
                Rngout<="0000" & RBINS;
--                Azmout<=ACPC_S;
                Extend<=Hitsin;
                Hitsout<="00000000";
                Missout<="00000000";
                history_out<='0';
                PID<=9;
            end if;
		------------------------
--			if Hitsin ="00000000" then
--				Hitsout<="00000000";
--				Missout<="00000000";
--				history_out<='0';
--				PID<=12;
--			else
--				if Missin < Miss_S  and history_in ='1'  then 				-- MISS = 6
--					Missout<=Missin+"00000001";
--					Hitsout<=Hitsin;
--					history_out<='0';
--					PID<=12;
--				elsif Missin < Miss_S and history_in ='0'  then 				-- MISS = 6
--					Missout<=Missin+"00000010";
--					Hitsout<=Hitsin;
--					history_out<='0';
--					PID<=12;
--				else
--					if Hitsin < Hits_S then		-- Hits = 24
--						Missout<="00000000";
--						Hitsout<="00000000";
--						history_out<='0';
--						PID<=12;
--					else
--	                   	Rngout(15 downto 12)<="0000";			
--						Rngout(11 downto 0)<=RBINS;						-- Traget out decesion  miss 6  hit 16
--						Azmout<=(ACPC-(Hitsin(7 downto 1)))-6;
--						Extend<=Hitsin;
----						Hitsout<=Hitsin;
----						Missout<=Missin+"0001";
----						history_out<='0';
--						PID<=9;
--					end if;
----				elsif Missin >  "0110"  and Missin <  "1111" then 		-- Keep alive taregt  		
----						Missout<=Missin+"0001";
----						Hitsout<=Hitsin;
----						history_out<='0';
----						PID<=12;
----				elsif Missin >  "0110"  and Missin =  "1111" then 		-- erease targets hits & miss
----						Missout<="0000";
----						Hitsout<="00000000";
----						history_out<='0';
----						PID<=12;
--				end if;
--			end if;
			--------------------------------------------------
		when 9 =>
				Missout<="00000000";
				Hitsout<="00000000";
				history_out<='0';
				Trig<='1';
				PID<=10;
		when 10 =>
				WE<='1';
				PID<=11;
		when 11 =>
		      Ramclk <='1';
				PID<=12;
		when 12 =>
				Ramclk <='0';
				PID<=13;
		when 13 =>
				Ramclk <='1';
				PID<=14;
		when 14 =>
				Ramclk <='0';
				PID<=15;
		when 15 =>
				if QV='0' then 
				
				PID<=16;
				end if;
		when 16 =>				
			if (ONEM_S='1') then
			 WE<='0';
				PID <=3;
			end if;
			
			when 17 =>
                Ramclk <='1';
                PID<=18;
            when 18 =>
                Ramclk <='0';
                PID<=7;
end case;
end if;
end process;
end Behavioral;



--entity BI_W is
--port (
--	Kitclk 		: in std_logic;
--	OneM			: in std_logic;
--	RST			: in std_logic;
--	CFARdecision: in std_logic;
--	Ro				: in std_logic;
--	RBINS			: in std_logic_vector(11 downto 0);
--	RAM_ADD			: OUT std_logic_vector(11 downto 0);
--	ACPC			: in std_logic_vector(15 downto 0);
--	Hitsin		: in std_logic_vector(7 downto 0);
--	Missin		: in std_logic_vector(7 downto 0);
--	Hits        : in std_logic_vector(7 downto 0);
--	history_in  : in std_logic;
--	history_out  : out std_logic;
--	Miss        : in std_logic_vector(7 downto 0);
--	Hitsout		:out std_logic_vector(7 downto 0);
--	pidout		:out std_logic_vector(7 downto 0);
--	Missout		:out std_logic_vector(7 downto 0);
--	WE				:out std_logic_vector(0 downto 0):="0";
--	Ramclk		:out std_logic:='0';
--	Trig			:out std_logic:='0';
--	Rngout		:out std_logic_vector(15 downto 0);
--	Azmout		:out std_logic_vector(15 downto 0);
--	Extend		:out std_logic_vector(7 downto 0));
--end BI_W;

--architecture Behavioral of BI_W is
--signal PID: integer range 0 to 35 :=0;
--SIGNAL ACPC_S: STD_LOGIC_VECTOR (15 DOWNTO 0);

--begin
--pidout<=std_logic_vector(to_unsigned(pid,8));
--process(oneM,RST,kitclk,Ro,RBINS)

--begin
--if RST ='1' then 
--PID<=0;
--elsif rising_edge (kitclk)then 
--	case PID is
--		when 0 =>
--			if Ro ='1' then 
--			PID<=1;
--			end if;
--		when 1 =>    -- write zero to all addresses in the RAM
--			if Ro ='0' then 
--				Missout<="00000000";
--				Hitsout<="00000000";
--				history_out<='0';
--				WE <="1";    -- write mode
--				Ramclk<= not(OneM);
--				RAM_ADD<=RBINS;
--				PID<=2;
--			end if;
--		when 2 =>
--				WE <="1";
--				RAM_ADD<=RBINS;
--				Ramclk<= not(OneM);
--			if Ro ='1' then 
--				WE<="0";
--				Ramclk<='0';
--				PID <=3;
--			end if;
--		when 3 =>
--			if (oneM='0')  then
--			RAM_ADD<=RBINS;
--			ACPC_S<=ACPC+"0000000010101010";
--			PID <=4;
--			end if;
--		when 4 =>
--			WE<="0";  -- read mode
--			IF ACPC_S >= 4096 THEN 
--			ACPC_S<=ACPC_S-4096;
--			END IF;
--			PID<=5;
--		when 5 =>
--			Ramclk <='1';  -- read clk
--			PID<=6;
--		when 6 =>
--			Ramclk <='0';  --read clk
--			PID<=7;
--		when 7 =>
--			if CFARdecision ='1'     and RBINS >"000011110011" and history_in ='1' then  -- Skip the first 280 range cells that contain clutter.
--				Hitsout<=Hitsin+"00000010";
--				Missout<=Missin;
--				history_out<='1';
--				PID<=32;
--			elsif CFARdecision ='1'     and RBINS >"000011110011" and history_in ='0' then  -- Skip the first 280 range cells that contain clutter.
--                Hitsout<=Hitsin+"00000001";
--                Missout<=Missin;
--                history_out<='1';
--                PID<=32;
--			else
--				PID<=8;
--			end if;
--		when 8 =>
--			if Hitsin ="00000000" then
--				Hitsout<="00000000";
--				Missout<="00000000";
--				history_out<='0';
--				PID<=32;
--			elsif Hitsin > "00000000" and Hitsin < Hits and Missin < Miss and history_in ='1' then  --"00000101"
--				Missout<=Missin+"00000001";
--				Hitsout<=Hitsin;
--				history_out<='0';
--				PID<=32;
--			elsif Hitsin > "00000000" and Hitsin < Hits and Missin < Miss and history_in ='0' then  --"00000101"
--                    Missout<=Missin+"00000010";
--                    Hitsout<=Hitsin;
--                    history_out<='0';
--                    PID<=32;
--			elsif Hitsin > "00000000" and Hitsin >= Hits and Missin < Miss and history_in ='1'  then --"00000101"
--				Missout<=Missin+"00000001";
--				Hitsout<=Hitsin;
--				history_out<='0';
--				PID<=32;
--			elsif Hitsin > "00000000" and Hitsin >= Hits and Missin < Miss and history_in ='0'  then --"00000101"
--                Missout<=Missin+"00000010";
--                Hitsout<=Hitsin;
--                history_out<='0';
--                PID<=32;
--			elsif Hitsin > "00000000" and Hitsin < Hits and Missin >= (Miss) then --"00000110"
--				Missout<="00000000";
--				Hitsout<="00000000";
--				history_out<='0';
--				PID<=32;
--			elsif Hitsin > "00000000" and Hitsin >= Hits and Missin >= (Miss ) then -- "00000110"
--				Rngout<="0000" & RBINS;
--				Azmout<=ACPC_S;
--				Extend<=Hitsin;
--				Hitsout<="00000000";
--				Missout<="00000000";
--				history_out<='0';
--				PID<=9;
--			end if;
--		when 9 =>
		          
--				Trig<='1';
--				PID<=10;
--		when 10 =>
--				Trig<='0';
--				PID<=11;
--		WHEN 11 =>
--		         WE<="1"; 
--		         RAM_ADD<=RBINS;
--		         PID<=12;
--        when 12 =>
--                 Ramclk <='1';   --write clk
--                 PID<=13;
--         when 13 =>
--                 Ramclk <='0';    --write clk
--                 PID<=14;
--         WHEN 14 =>
--                 RAM_ADD<=RBINS+1;
--		         PID<=15;
--        when 15 =>
--                 Ramclk <='1';   --write clk
--                 PID<=16;
--         when 16 =>
--                 Ramclk <='0';    --write clk
--                 PID<=17;
--         WHEN 17 =>
--                 RAM_ADD<=RBINS+2;
--		         PID<=18;
--        when 18 =>
--                 Ramclk <='1';   --write clk
--                 PID<=19;
--         when 19 =>
--                 Ramclk <='0';    --write clk
--                 PID<=20;
--         WHEN 20 =>
--                 RAM_ADD<=RBINS+3;
--		         PID<=21;
--        when 21 =>
--                 Ramclk <='1';   --write clk
--                 PID<=22;
--         when 22 =>
--                 Ramclk <='0';    --write clk
--                 PID<=23;
--         WHEN 23 =>
--                 RAM_ADD<=RBINS-1;
--		         PID<=24;
--        when 24 =>
--                 Ramclk <='1';   --write clk
--                 PID<=25;
--         when 25 =>
--                 Ramclk <='0';    --write clk
--                 PID<=26;
--         WHEN 26 =>
--                 RAM_ADD<=RBINS-2;
--		         PID<=27;
--        when 27 =>
--                 Ramclk <='1';   --write clk
--                 PID<=28;
--         when 28 =>
--                 Ramclk <='0';    --write clk
--                 PID<=29;
--         WHEN 29 =>
--                 RAM_ADD<=RBINS-3;
--		         PID<=30;
--        when 30 =>
--                 Ramclk <='1';   --write clk
--                 PID<=31;
--         when 31 =>
--                 Ramclk <='0';    --write clk
--                 PID<=32;
--         WHEN 32 =>
--				WE<="1";   -- write mode
--				PID<=33;
--		when 33 =>
--			Ramclk <='1';   --write clk
--			PID<=34;
--		when 34 =>
--			Ramclk <='0';    --write clk
--			PID<=35;
--		when 35 =>				
--			if (oneM='1') then
--				PID <=3;
--			end if;
--end case;
--end if;
--end process;
--end Behavioral;