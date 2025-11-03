library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all;
use work.u_size.all;

-- ENTITY ----------------------------------------------------
-- This entity handles the user set config with a user set command input
-- It can be mapped to 'user set' I/F of the wrapper in order to allow access 
--   and storing of config bit register through 'user set' requests
-- It can be mapped to 'user set' decoder I/F (one of the 8 decoded line) without user set command of the wrapper
--   in this case, x_sel_user_set_cmd AND x_user_set_cmd are left unconnected
-- It can also be mapped to 'user set cmd' I/F with user set command of the wrapper in order to allow up to 16-bits addressing
--   in this case, connect x_user_set_req/x_user_set_cmd to x_user_set_cmd_req/x_user_set_cmd of decoder and 
--   fix x_sel_user_set_cmd value to be mapped to this entity
entity UFP_USER_SET_CONFIG is
	Generic(
		x_reset_active 		: STD_LOGIC := '0';
		x_nb_addr_bits			: natural := 4;	-- Addr lines (MIN=0;MAX=15) => 2^x_nb_addr_bits = nb of data word allowed, data word width = 16-x_nb_addr_bits 
		x_nb_data_word			: positive := 16;	-- Nb of word to be used, must be =< 2^x_nb_addr_bits => nb of total bits = x_nb_data_word*(16-x_nb_addr_bits)
		x_user_set_cmd_size	: positive := 16	-- nb of user_set_cmd bits used	(can be reduced for synthetis optimisation)	
		);
   Port ( 
		x_clk						: in std_logic;
		x_nreset					: in std_logic;
		-- user set command to be decoded when using decoder x_user_set_cmd_req, must be left unconnected when using decoder x_user_set_req
		x_sel_user_set_cmd	: std_logic_vector(x_user_set_cmd_size-1 downto 0) := (others=>'0');	-- selection of user set cmd to be mapped for this config (compared to x_user_set_cmd of decoder)
		-- DECODER interface
		x_user_set_req			: in std_logic; -- to be connected to x_user_set_req or x_user_set_cmd_req of decoder
		x_user_set_cmd			: in std_logic_vector(x_user_set_cmd_size-1 downto 0) := (others=>'0');	-- not mandatory if using decoder x_user_set_req only
		x_param_in				: in U_T_DATAWIDTH_16;
		x_user_set_ack			: out std_logic;
		x_user_set_error		: out std_logic;
		x_user_set_error_d	: out U_T_DATAWIDTH_4;
		x_busy					: out std_logic; -- allow the user to know that the get config is busy and will ack	
		-- Register output, updated upon user set request. Bit0 = LSB
		x_registers				: out STD_LOGIC_VECTOR(x_nb_data_word*(16-x_nb_addr_bits)-1 downto 0)
		);
end UFP_USER_SET_CONFIG;

-- ARCHITECTURE  ---------------------------------------------
architecture Behavioral of UFP_USER_SET_CONFIG is
	attribute keep : boolean;

	-- Constants -------------------------------------------------
	constant C_WORD_SIZE : positive := 16-x_nb_addr_bits;
	
	-- Types -----------------------------------------------------
	type T_STATE is (IDLE, STORE, ACK, ERR);
	type T_BUS_ARRAY	is array(natural range <>) of std_logic_vector;
	
	-- Signals ---------------------------------------------------
	signal sl_int_state, sl_next_state : T_STATE;
	
	signal sl_int_reg, sl_next_reg					: T_BUS_ARRAY(x_nb_data_word-1 downto 0)(C_WORD_SIZE-1 downto 0);	-- register latch
	attribute keep of sl_int_reg : signal is true;
	
-- components declaration ------------------------------------

BEGIN
-- Component Instantiation -----------------------------------	
	
-- combinatorial ---------------------------------------------
	
-- others process -----------------------------------------------
	p_state : process(sl_int_state, x_user_set_req, x_param_in, sl_int_reg, x_user_set_cmd, x_sel_user_set_cmd)
	begin
		sl_next_state 	<= sl_int_state;
		sl_next_reg		<= sl_int_reg;
			
		case sl_int_state is		
			------------------------------------------
			when IDLE =>
				if (x_user_set_req = '1') and (x_user_set_cmd = x_sel_user_set_cmd) then					
					if (x_nb_addr_bits>0) then 	-- multiple words
						-- check addr is below nb of data word allowed
						if (x_param_in(15 downto C_WORD_SIZE) <= CONV_STD_LOGIC_VECTOR(x_nb_data_word-1, x_nb_addr_bits)) then
							sl_next_state <= STORE;
						else
							sl_next_state <= ERR;
						end if;
					else -- 1 word 16
						sl_next_reg(0) <= x_param_in;
						sl_next_state <= ACK;
					end if;
				end if;

			------------------------------------------				
			when STORE	=> -- only here if multiple words
				-- demux the addr to the register
				if (x_nb_addr_bits>0) then
					sl_next_reg(CONV_INTEGER(x_param_in(15 downto C_WORD_SIZE))) <= x_param_in(C_WORD_SIZE-1 downto 0);
				end if;
				sl_next_state <= ACK;
			
			------------------------------------------
			when ACK|ERR	=>
				sl_next_state <= IDLE;
				
		end case;
	end process;
	
	
-- clk process -----------------------------------------------
	p_clk : process(x_nreset, x_clk)
	begin
		if (x_nreset = x_reset_active) then
			for l_i in 0 to x_nb_data_word-1 loop
				sl_int_reg(l_i) <= (others =>'0');
			end loop;
			sl_int_state		<= IDLE;
	   elsif (x_clk='1') and (x_clk'event) then
			sl_int_reg			<= sl_next_reg;
			sl_int_state		<= sl_next_state;
		end if;
	end process;

-- outputs ---------------------------------------------------	
	x_user_set_ack			<= '1' when (sl_int_state = ACK) or (sl_int_state = ERR) else '0';
	x_user_set_error		<= '1' when (sl_int_state = ERR) else '0';
	x_user_set_error_d	<= X"0";
	x_busy					<= '1' when (sl_int_state /= IDLE) else '0';
	
	--wrap registers
	p_out : process (sl_int_reg)
	begin
		for l_i in 0 to x_nb_data_word-1 loop		
			x_registers(C_WORD_SIZE*(l_i+1)-1 downto C_WORD_SIZE*l_i)	<= sl_int_reg(l_i);
		end loop;
	end process;
	
end Behavioral;