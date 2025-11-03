library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.Numeric_STD.all;
use work.FPS_SlowControl.all;

-- ENTITY ----------------------------------------------------

entity FPS_SC_FEEDER_tb is
end FPS_SC_FEEDER_tb;

-- ARCHITECTURE  ---------------------------------------------
Architecture rtl of FPS_SC_FEEDER_tb is
-- Constants -------------------------------------------------
-- Types -----------------------------------------------------		
-- aliases----------------------------------------------------
-- Signals ---------------------------------------------------

	signal x_nreset	 	: STD_LOGIC;	
	signal x_clk		: STD_LOGIC;
	signal x_data		: std_logic_vector(15 downto 0);
	signal x_wraddress	: std_logic_vector(7 downto 0);
	signal x_wr			: std_logic;
	signal x_q			: std_logic_vector(15 downto 0);
	signal x_rdaddress	: std_logic_vector(7 downto 0);

	signal x_start 			: std_logic := '0';
   	signal x_valid_in 		: std_logic;
   	signal x_sel 			: std_logic_vector(1 downto 0);
   	signal x_spi_ack 		: std_logic := '0';
   	signal x_chip_address 	: std_logic_vector(2 downto 0) := "101";
   	signal x_super_column	: std_logic_vector(3 downto 0) := "0011";
   	signal x_spi_req 		: std_logic;
   	signal x_spi_reg 		: std_logic_vector(19 downto 0);
   	signal x_ack 			: std_logic;
   	signal x_err 			: std_logic;
   	signal sl_int_rdaddress_feeder	: std_logic_vector(7 downto 0);
   	signal sl_int_rdaddress_filler	: std_logic_vector(7 downto 0);
   	signal x_spi_cmd : std_logic_vector(5 downto 0) := "010101";
   	signal x_spi_data_cmd  : std_logic_vector(7 downto 0) := "01010111" ;


-- Components ------------------------------------------------

component DPRAM IS
	PORT
	(
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdaddress	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wraddress	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC  := '0';
		q			: OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
	);
END component;

	procedure write_DPRAM(	signal x_wraddress : out std_logic_vector(7 downto 0);
							signal x_data : out std_logic_vector(15 downto 0);
							signal x_wr : out STD_LOGIC;
							x_wraddr_in : in std_logic_vector(7 downto 0);
							x_data_in : in std_logic_vector(15 downto 0)) is
	begin
		wait until x_clk = '1';
		x_wraddress 	<= x_wraddr_in;
		x_data 		<= x_data_in;
		x_wr 		<= '1';

	end procedure write_DPRAM;

	procedure fill_DPRAM(	signal x_wraddress : out std_logic_vector(7 downto 0);
							signal x_data : out std_logic_vector(15 downto 0);
							signal x_wr : out STD_LOGIC) is
	
	variable var_data : std_logic_vector(15 downto 0) := X"0080";
	variable var_wraddr : std_logic_vector(7 downto 0) := "00000000";
	
	begin
		for cnt_val in 0 to 256 loop
			write_DPRAM(x_wraddress, x_data, x_wr, var_wraddr, var_data);

			var_data := var_data + 1;
			var_wraddr := var_wraddr + 1;
		end loop;
		x_wr <= '0';
		var_data := X"0080";
		var_wraddr := "00000000";

	end procedure fill_DPRAM;

begin
	-------------------------------------------------------------------------------
	-- components instanciation
	-------------------------------------------------------------------------------

	C_DPRAM : DPRAM
	port map (
		clock 		=> x_clk,
		data 		=> x_data,
		rdaddress 	=> x_rdaddress,
		wraddress 	=> x_wraddress,
		wren 		=> x_wr,
		q 			=> x_q);

	C_FPS_SC_FEEDER : FPS_SC_FEEDER
	Port map (	x_nreset	=> x_nreset,
			x_clk 			=> x_clk,
			x_start 		=> x_start,
   			x_valid_word    => x_valid_in,
   			x_spi_cmd 		=> x_spi_cmd,
   			x_spi_data_cmd  => x_spi_data_cmd,
   			x_sel 			=> x_sel,
   			x_spi_ack 		=> x_spi_ack,
   			x_chip_address 	=> x_chip_address,
   			x_dpram_q 		=> x_q,
   			x_super_column	=> x_super_column,
   			x_spi_req 		=> x_spi_req,
   			x_dpram_address => sl_int_rdaddress_feeder,
   			x_spi_reg 		=> x_spi_reg,
   			x_ack 			=> x_ack,
   			x_err 			=> x_err);

	-------------------------------------------------------------------------------
	-- COMBINATORIAL --------------------------------------------------------------
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- PROCESS --------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-------------------------------------------------------------------------------
	-- COMBINATORIAL process ------------------------------------------------------
	p_state : process(all)
	begin

	end process;

	-------------------------------------------------------------------------------
	-- CLOCK process --------------------------------------------------------------
	p_clk : process  --50MHz
	begin
		x_clk <= '1';
		wait for 10 ns;
		x_clk <= '0';
		wait for 10 ns;
	end process;

	p_testbench : PROCESS
	variable var_programming_count : integer := 0;
	begin
		x_nreset <= '0';
		sl_int_rdaddress_filler <= (others => '0');
		x_data <= (others => '0');
		x_wr <= '0';
		sl_int_rdaddress_filler <= "00000000";
		x_wraddress <= (others => '0');
		x_valid_in <= '1';
		x_sel <= "00";

		wait for 30 ns;

		report "starting test... " & time'image(now);

		x_nreset    <= '1';

		report "Start filling the DPRAM ... " & time'image(now);
		fill_DPRAM(x_wraddress, x_data, x_wr); -- Fill DPRAM with 128 to 383 (arbitrary values)
		report "Done filling the DPRAM ... " & time'image(now);

		wait until x_clk = '1';
		x_valid_in <= '0';
		x_start <= '1';
		x_sel <= "00";
		
		wait until x_clk = '1';
		x_start <= '0';
		
		wait until x_clk = '1';
		wait until x_clk = '1';
		wait until x_clk = '1';
		
		x_valid_in <= '0';
		x_start <= '1';
		x_sel <= "01";

		wait until x_clk = '1';
		x_start <= '0';
		x_valid_in <= '1';
		wait until x_clk = '1';
		
		for x_sel_cnt in 0 to 3 loop
			
			x_sel <= std_logic_vector(to_unsigned(x_sel_cnt, x_sel'length));
			wait until x_clk = '1';
			report "x_sel = " & to_string(x_sel) & " : Start reg check ... " & time'image(now);	
			
			x_start <= '1';

			if(x_sel = "00") then
				for cnt_val in 0 to 511 loop
					wait until x_clk = '1';
					wait until x_clk = '1';
					wait until x_clk = '1';
					wait until x_clk = '1';
					
					if(var_programming_count = 0) then
						assert (x_spi_reg = "00" & "000010" & x_chip_address & '0' & x_q(15 downto 8)) report "Error checking x_spi_reg (expect 0b0000010" & to_string(x_chip_address) & "0" & to_string(x_q(15 downto 8)) & "; read 0b" & to_string(x_spi_reg) & ")" severity failure;
					elsif (var_programming_count = 2) then
						assert (x_spi_reg = "00" & "000010" & x_chip_address & '0' & x_q(7 downto 0)) report "Error checking x_spi_reg (expect 0b0000010" & to_string(x_chip_address) & "0" & to_string(x_q(7 downto 0)) & "; read 0b" & to_string(x_spi_reg) & ")" severity failure;
					elsif (var_programming_count = 1 or var_programming_count = 3) then
						assert (x_spi_reg = "1" & "0000" & x_super_column(2 downto 0) & x_chip_address & x_super_column(3) & "00000000") report "Error checking x_spi_reg (expect 0b10000" & to_string(x_super_column(2 downto 0)) & to_string(x_chip_address) & to_string(x_super_column(3)) & "00000000" & "; read 0b" & to_string(x_spi_reg) & ")" severity failure;
					end if;	

					wait until x_clk = '1';
					x_spi_ack <= '1';
					wait until x_clk = '1';
					x_spi_ack <= '0';

					if(var_programming_count = 3) then
						var_programming_count := 0;
					else
						var_programming_count := var_programming_count + 1;
					end if;
				end loop;
			elsif x_sel = "01" then
				for cnt_val in 0 to 1023 loop
					wait until x_clk = '1';
					wait until x_clk = '1';
					wait until x_clk = '1';
					wait until x_clk = '1';
					
					if(var_programming_count = 0) then
						assert (x_spi_reg = "00" & "000010" & x_chip_address(2 downto 1) & x_rdaddress(7) & '0' & x_q(15 downto 8)) report "Error checking x_spi_reg (expect 0b00000010" & to_string(x_chip_address(2 downto 1)) & to_string(x_rdaddress(7)) & "0" & to_string(x_q(15 downto 8)) & "; read 0b" & to_string(x_spi_reg) & ")" severity failure;
					elsif (var_programming_count = 2) then
						assert (x_spi_reg = "00" & "000010" & x_chip_address(2 downto 1) & x_rdaddress(7) & '0' & x_q(7 downto 0)) report "Error checking x_spi_reg (expect 0b00000010" & to_string(x_chip_address(2 downto 1)) & to_string(x_rdaddress(7)) & "0" & to_string(x_q(7 downto 0)) & "; read 0b" & to_string(x_spi_reg) & ")" severity failure;
					elsif (var_programming_count = 1 or var_programming_count = 3) then
						assert (x_spi_reg = "1" & "0000" & x_super_column(2 downto 0) & x_chip_address(2 downto 1) & x_rdaddress(7) & x_super_column(3) & "00000000") report "Error checking x_spi_reg (expect 0b10000" & to_string(x_super_column(2 downto 0)) & to_string(x_chip_address(2 downto 1)) & to_string(x_rdaddress(7)) & to_string(x_super_column(3)) & "00000000" & "; read 0b" & to_string(x_spi_reg) & ")" severity failure;
					end if;	

					wait until x_clk = '1';
					x_spi_ack <= '1';
					wait until x_clk = '1';
					x_spi_ack <= '0';

					if(var_programming_count = 3) then
						var_programming_count := 0;
					else
						var_programming_count := var_programming_count + 1;
					end if;
				end loop;
			elsif x_sel = "10" then
				wait until x_clk = '1';
				wait until x_clk = '1';
				wait until x_clk = '1';
				assert (x_spi_reg = "00" & x_spi_cmd & x_chip_address & '0' & x_spi_data_cmd) report "Error checking x_spi_reg (expect 0b00" & to_string(x_spi_cmd) & to_string(x_chip_address) & "0" & to_string(x_spi_data_cmd) & "; read 0b" & to_string(x_spi_reg) & ")" severity failure;
				
				wait until x_clk = '1';
				x_spi_ack <= '1';
				wait until x_clk = '1';
				x_spi_ack <= '0';

				wait until x_clk = '1';
				x_start <= '0';
				x_spi_cmd <= "000010";

				wait until x_clk = '1';
				x_start <= '1';

				wait until x_clk = '1';
				wait until x_clk = '1';
				wait until x_clk = '1';
				assert (x_spi_reg = "00" & x_spi_cmd & x_chip_address & '0' & x_spi_data_cmd) report "Error checking x_spi_reg (expect 0b00" & to_string(x_spi_cmd) & to_string(x_chip_address) & "0" & to_string(x_spi_data_cmd) & "; read 0b" & to_string(x_spi_reg) & ")" severity failure;
				
				wait until x_clk = '1';
				x_spi_ack <= '1';
				wait until x_clk = '1';
				x_spi_ack <= '0';

				wait until x_clk = '1';
				wait until x_clk = '1';
				wait until x_clk = '1';
				assert (x_spi_reg = "1" & "0000" & x_super_column(2 downto 0) & x_chip_address & x_super_column(3) & "00000000") report "Error checking x_spi_reg (expect 0b00" & to_string(x_spi_cmd) & to_string(x_chip_address) & "0" & to_string(x_spi_data_cmd) & "; read 0b" & to_string(x_spi_reg) & ")" severity failure;
				
				wait until x_clk = '1';
				x_spi_ack <= '1';
				wait until x_clk = '1';
				x_spi_ack <= '0';

				x_spi_cmd <= "010101";

			elsif x_sel = "11" then
				wait until x_clk = '1';
				wait until x_clk = '1';
				wait until x_clk = '1';
				assert (x_spi_reg = "11000000000000000000") report "Error checking x_spi_reg (expect 0b11000000000000000000" & "; read 0b" & to_string(x_spi_reg) & ")" severity failure;
				
				wait until x_clk = '1';
				x_spi_ack <= '1';
				wait until x_clk = '1';
				x_spi_ack <= '0';

			end if;

			report "x_sel = " & to_string(x_sel) & " : Done reg check ... " & time'image(now);
			
			wait until x_clk = '1';
			x_start <= '0';

		end loop;

		----------------------------------------------------
		report "TEST SUCCESSFULL ... " & time'image(now);
		---------------------------------------------------
		wait; -- will wait forever
	end process;
	
	-------------------------------------------------------------------------------
	-- OUTPUTS --------------------------------------------------------------------
	-------------------------------------------------------------------------------

	x_rdaddress <= sl_int_rdaddress_feeder when (x_start = '1') else sl_int_rdaddress_filler;

end rtl;