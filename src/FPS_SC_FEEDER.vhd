----------------------------------------------------------------------------------
-- Company.......: Université de Genève - DPNC
-- Author........: Terry Baltus
-- File..........: FPS_SC_FEEDER.vhd
-- Description...: SPI FEEDER
-- Project Name..: FaserPreShower
-- Created.......: Jul 08, 2022
-- Version.......: -
--
-- Revision History:
-- Jul 08, 2022: file creation
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.Numeric_STD.all;

-- ENTITY ----------------------------------------------------
-- FPS_SC_FEEDER: This entity handles the configuration and control of DPRAM and SPI communication, 
-- managing the transfer of data between an FPGA and external components. It supports multiple modes,
-- including DPRAM address setting, SPI command execution, and reset operations. It interfaces with a 
-- wrapper, user configuration settings, and SPI peripherals, ensuring correct data flow and synchronization.

entity FPS_SC_FEEDER is
	Generic(
		x_reset_active : std_logic := '0'
	);
	Port (	
		x_nreset		: in  	std_logic;
		x_clk 			: in  	std_logic;
		
		--Wrapper interface------
		x_start 		: in  	std_logic; --The wrapper keeps it valid until ack (required for dpram address multiplexing)
		x_ack 			: out 	std_logic; --Valid for one clock cycle when data transfer's finished
		x_err 			: out 	std_logic; --Generates an error if when start, valid_word is different from 1
		x_valid_word    : in  	std_logic; --Is valid if computer dpram image is equal to fpga dpram image (send, read, verify)
		
		--UserSetCfg interface---
		x_spi_cmd		: in 	std_logic_vector(5 downto 0); --constant over data transfer
		x_spi_data_cmd 	: in 	std_logic_vector(7 downto 0); --constant over data transfer
		x_chip_address 	: in  	std_logic_vector(2 downto 0); --constant over data transfer
		x_super_column	: in  	std_logic_vector(3 downto 0); --constant over data transfer
		x_sel 			: in  	std_logic_vector(1 downto 0); --"00" is dpram configuration, "10" is command configuration, "01" is dpram_cal configuration, constant over data transfer
		
		--DPRAM interface--------
		x_dpram_address : out 	std_logic_vector(7 downto 0);
		x_dpram_q 		: in  	std_logic_vector(15 downto 0);
		
		--SPI interface----------
		x_spi_req 		: out 	std_logic; --Valid until ack
		x_spi_reg 		: out 	std_logic_vector(19 downto 0); --Must be kept valid until ack
		x_spi_ack 		: in  	std_logic --Valid for one clock cycle when finished
   	);
end FPS_SC_FEEDER;

-- ARCHITECTURE  ---------------------------------------------
Architecture rtl of FPS_SC_FEEDER is
-- Constants -------------------------------------------------
		
-- Types -----------------------------------------------------		
	type type_state is (IDLE, DPRAM_ADDR_SET, DPRAM_SPI_PREPARE, DPRAM_SPI_START, COMMAND_SPI_PREPARE, COMMAND_SPI_START_AND_PUSH_PREPARE, COMMAND_SPI_START, RESET_SPI_PREPARE, RESET_SPI_START, ACK_ERR, ACK);
	subtype programming_count_type is integer range 0 to 3;
-- aliases----------------------------------------------------
	
-- Signals ---------------------------------------------------
	signal sl_int_state	 : type_state;
	signal sl_next_state : type_state;

	signal sl_int_programming_count : programming_count_type;
	signal sl_next_programming_count : programming_count_type;

	signal sl_int_address_count : std_logic_vector(7 downto 0);
	signal sl_next_address_count : std_logic_vector(7 downto 0);

	signal sl_int_reg : std_logic_vector(19 downto 0);
	signal sl_next_reg : std_logic_vector(19 downto 0);

	signal sl_int_last_addr : std_logic_vector(7 downto 0);

-- Components ------------------------------------------------

	
begin
	-------------------------------------------------------------------------------
	-- components instanciation
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- COMBINATORIAL --------------------------------------------------------------
	-------------------------------------------------------------------------------

	sl_int_last_addr <= 	"01111111" when (x_sel = "00") else
							"11111111"; -- used when x_sel = "01", NB: sl_int_last_addr unused when x_sel = "10"/x_sel = "11"

	-------------------------------------------------------------------------------
	-- PROCESS --------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- COMBINATORIAL process ------------------------------------------------------
	p_state : process(all)
	begin

		sl_next_state 				<= sl_int_state;
		sl_next_address_count 		<= sl_int_address_count;
		sl_next_programming_count 	<= sl_int_programming_count;
		sl_next_reg					<= sl_int_reg;

		case(sl_int_state) is
			when IDLE =>
				sl_next_address_count <= (others => '0');
				if(x_start = '1') then
					if (x_sel = "00" or x_sel = "01") then
						if(x_valid_word = '1') then
							sl_next_state <= DPRAM_ADDR_SET;
						else
							sl_next_state <= ACK_ERR;
						end if;
					elsif(x_sel = "10") then
						sl_next_state <= COMMAND_SPI_PREPARE;
					elsif (x_sel = "11") then
						sl_next_state <= RESET_SPI_PREPARE;
					end if;
				end if;

			when DPRAM_ADDR_SET =>
				sl_next_programming_count <= 0;
				sl_next_state <= DPRAM_SPI_PREPARE;

			when DPRAM_SPI_PREPARE =>
				if (sl_int_programming_count = 0) then -- SPI send prog word / 1st 8-bits DPRAM data
					if(x_sel = "00") then
						sl_next_reg <= "00" & "000010" & x_chip_address & '0' & x_dpram_q(15 downto 8);
					else
						sl_next_reg <= "00" & "000010" & x_chip_address(2 downto 1) & sl_int_address_count(7) & '0' & x_dpram_q(15 downto 8); -- sel = 01 allows a parallel configuration of a pair of chips for the selected super-column
					end if;		
				elsif (sl_int_programming_count = 2) then -- SPI send prog word / 2nd 8-bits DPRAM data
					if(x_sel = "00") then
						sl_next_reg <= "00" & "000010" & x_chip_address & '0' & x_dpram_q(7 downto 0);
					else
						sl_next_reg <= "00" & "000010" & x_chip_address(2 downto 1) & sl_int_address_count(7) & '0' & x_dpram_q(7 downto 0); -- sel = 01 allows a parallel configuration of a pair of chips for the selected super-column
					end if;	
				else  -- SPI push
					if(x_sel = "00") then
						sl_next_reg <= "10" & "000" & x_super_column(2 downto 0) & x_chip_address & x_super_column(3) & "00000000";
					else
						sl_next_reg <= "10" & "000" & x_super_column(2 downto 0) & x_chip_address(2 downto 1) & sl_int_address_count(7) & x_super_column(3) & "00000000"; -- sel = 01 allows a parallel configuration of a pair of chips for the selected super-column 
					end if;	
				end if ;

				sl_next_state <= DPRAM_SPI_START;

			when DPRAM_SPI_START =>
				if(x_spi_ack = '1' and sl_int_address_count = sl_int_last_addr and sl_int_programming_count = 3) then -- address = 127 if sel = 00, 255 if sel = 01
					sl_next_state <= ACK;
				elsif (x_spi_ack = '1' and sl_int_programming_count = 3) then
					sl_next_address_count <= sl_int_address_count + 1;
					sl_next_state <= DPRAM_ADDR_SET;
				elsif (x_spi_ack = '1') then
					sl_next_programming_count <= sl_int_programming_count + 1;
					sl_next_state <= DPRAM_SPI_PREPARE;
				end if;

			when COMMAND_SPI_PREPARE =>
				sl_next_reg <= "00" & x_spi_cmd & x_chip_address & '0' & x_spi_data_cmd;
				if(x_spi_cmd = "000010") then
					sl_next_state <= COMMAND_SPI_START_AND_PUSH_PREPARE;
				else
					sl_next_state <= COMMAND_SPI_START;
				end if;

			when COMMAND_SPI_START_AND_PUSH_PREPARE =>
				if(x_spi_ack = '1') then
					sl_next_reg <= "10" & "000" & x_super_column(2 downto 0) & x_chip_address & x_super_column(3) & "00000000";
					sl_next_state <= COMMAND_SPI_START;
				end if;

			when COMMAND_SPI_START =>
				if(x_spi_ack = '1') then
					sl_next_state <= ACK;
				end if;

			when RESET_SPI_PREPARE =>
				sl_next_reg <= "11000000000000000000";
				sl_next_state <= RESET_SPI_START;

			when RESET_SPI_START =>
				if(x_spi_ack = '1') then
					sl_next_state <= ACK;
				end if;

			when ACK =>
				sl_next_state <= IDLE;

			when ACK_ERR =>
				sl_next_state <= IDLE;

		end case;
	end process;

	-------------------------------------------------------------------------------
	-- CLOCK process --------------------------------------------------------------
	p_clk : process (x_clk, x_nreset)
	begin
		if(x_nreset = x_reset_active) then
			sl_int_state 				<= IDLE;
			sl_int_address_count 		<= (others => '0');
			sl_int_programming_count 	<= 0;
			sl_int_reg 					<= (others => '0');
		elsif (x_clk'event and x_clk = '1') then
			sl_int_state 				<= sl_next_state;
			sl_int_address_count 		<= sl_next_address_count;
			sl_int_programming_count  	<= sl_next_programming_count;
			sl_int_reg 					<= sl_next_reg;
		end if;
	end process;
	
	-------------------------------------------------------------------------------
	-- OUTPUTS --------------------------------------------------------------------
	-------------------------------------------------------------------------------
	
	x_dpram_address <= sl_int_address_count;
	x_spi_reg 		<= sl_int_reg;
	x_spi_req 		<= '1' when (sl_int_state = DPRAM_SPI_START or sl_int_state = COMMAND_SPI_START or sl_int_state = COMMAND_SPI_START_AND_PUSH_PREPARE or sl_int_state = RESET_SPI_START) else '0';
	x_ack 			<= '1' when (sl_int_state = ACK or sl_int_state = ACK_ERR) else '0';
	x_err 			<= '1' when (sl_int_state = ACK_ERR) else '0';

end rtl;