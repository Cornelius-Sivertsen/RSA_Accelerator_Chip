--------------------------------------------------------------------------------
-- Author       : Oystein Gjermundnes
-- Organization : Norwegian University of Science and Technology (NTNU)
--                Department of Electronic Systems
--                https://www.ntnu.edu/ies
-- Course       : TFE4141 Design of digital systems 1 (DDS1)
-- Year         : 2018-2019
-- Project      : RSA accelerator
-- License      : This is free and unencumbered software released into the
--                public domain (UNLICENSE)
--------------------------------------------------------------------------------
-- Purpose:
--   RSA encryption core template. This core currently computes
--   C = M xor key_n
--
--   Replace/change this module so that it implements the function
--   C = M**key_e mod key_n.
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity rsa_core is
	generic (
		-- Users to add parameters here
		C_BLOCK_SIZE          : integer := 256
	);
	port (
		-----------------------------------------------------------------------------
		-- Clocks and reset
		-----------------------------------------------------------------------------
		clk                    :  in std_logic;
		reset_n                :  in std_logic;

		-----------------------------------------------------------------------------
		-- Slave msgin interface
		-----------------------------------------------------------------------------
		-- Message that will be sent out is valid
		msgin_valid             : in std_logic;
		-- Slave ready to accept a new message
		msgin_ready             : out std_logic;
		-- Message that will be sent out of the rsa_msgin module
		msgin_data              :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		-- Indicates boundary of last packet
		msgin_last              :  in std_logic;

		-----------------------------------------------------------------------------
		-- Master msgout interface
		-----------------------------------------------------------------------------
		-- Message that will be sent out is valid
		msgout_valid            : out std_logic;
		-- Slave ready to accept a new message
		msgout_ready            :  in std_logic;
		-- Message that will be sent out of the rsa_msgin module
		msgout_data             : out std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		-- Indicates boundary of last packet
		msgout_last             : out std_logic;

		-----------------------------------------------------------------------------
		-- Interface to the register block
		-----------------------------------------------------------------------------
		key_e_d                 :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		key_n                   :  in std_logic_vector(C_BLOCK_SIZE-1 downto 0);
		rsa_status              : out std_logic_vector(31 downto 0)

	);
end rsa_core;

architecture rtl of rsa_core is

signal calculation_finished_sig : std_logic;

signal msgout_sig :std_logic;

signal ready_in : std_logic :='0';
signal pick_value_sig, pick_value_sig_nxt, give_value,give_value_nxt, deja_fait, deja_fait_nxt  : std_logic:= '0';


begin
	i_exponentiation : entity work.exponentiation
		generic map (
			C_block_size => C_BLOCK_SIZE
		)
		port map (
			message   => msgin_data  ,
			key       => key_e_d     ,
			valid_in  => msgin_valid ,
			ready_in  => ready_in,--msgin_ready ,
			ready_out => msgout_ready,
			valid_out => msgout_valid,--msgout_valid,
			result    => msgout_data ,
			calculation_finished_output => calculation_finished_sig,
			modulus   => key_n       ,
			clk       => clk         ,
			reset_n   => reset_n
		);
	
	
	
	msgout_last <= msgout_sig ;
	msgin_ready <= ready_in ;

	process (
		clk,
		reset_n
	)

    begin
		if reset_n = '0' then
			pick_value_sig <= '0';
			give_value <= '0';
			deja_fait <= '0';
		elsif rising_edge(clk) then
			pick_value_sig <= pick_value_sig_nxt;
			give_value <= give_value_nxt;
			deja_fait <= deja_fait_nxt;
		end if;
	end process;

    process (
		ready_in,
		msgin_valid,
		calculation_finished_sig,
		msgout_valid,
		msgout_ready
	)


    begin

		pick_value_sig_nxt <= pick_value_sig;
    	give_value_nxt <= give_value;
    	msgout_sig <= '0';
		

		pick_value_sig_nxt <= pick_value_sig;
    	give_value_nxt <= give_value;
    	msgout_sig <= '0';
		
		if ready_in = '1' and msgin_valid = '1' and deja_fait ='0' then
			pick_value_sig_nxt <= msgin_last;
			deja_fait_nxt <= '1';
		else 
			--pick_value_sig <= pick_value_sig;
			deja_fait_nxt <= '0';
		end if;

		if calculation_finished_sig = '1' then
			give_value_nxt <= pick_value_sig;
		-- else 
		-- 	give_value <= give_value;
			give_value_nxt <= pick_value_sig;
		-- else 
		-- 	give_value <= give_value;
		end if;

		if msgout_valid = '1' and msgout_ready ='1' then
			msgout_sig <= give_value;
		-- else
		-- 	msgout_sig <= '0';
		-- else
		-- 	msgout_sig <= '0';
		end if;
	end process;
    
    
	rsa_status   <= (others => '0');
	
end rtl;
