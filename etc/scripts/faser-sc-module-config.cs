int odd_even_SC_masking_conversion(int row_mask, int super_column_nb)
{
    if(super_column_nb % 2 == 1) 
    {
        string conversion_str = Convert.ToString(row_mask, 2).PadLeft(16, '0');
        conversion_str = String.Concat( conversion_str[15],
                                        conversion_str[14],
                                        conversion_str[13],
                                        conversion_str[12],
                                        conversion_str[11],
                                        conversion_str[10],
                                        conversion_str[9],
                                        conversion_str[8],
                                        conversion_str[7],
                                        conversion_str[6],
                                        conversion_str[5],
                                        conversion_str[4],
                                        conversion_str[3],
                                        conversion_str[2],
                                        conversion_str[1],
                                        conversion_str[0]);

        return Convert.ToInt32(conversion_str, 2);
    }
    else
    {
    	string conversion_str = Convert.ToString(row_mask, 2).PadLeft(16, '0');
		conversion_str = String.Concat( conversion_str[8],
                                        conversion_str[9],
                                        conversion_str[10],
                                        conversion_str[11],
                                        conversion_str[12],
                                        conversion_str[13],
                                        conversion_str[14],
                                        conversion_str[15],
                                        conversion_str[0],
                                        conversion_str[1],
                                        conversion_str[2],
                                        conversion_str[3],
                                        conversion_str[4],
                                        conversion_str[5],
                                        conversion_str[6],
                                        conversion_str[7]);

        return Convert.ToInt32(conversion_str, 2);
    }
}

void ScriptMain()
{
	int sel 				= 0;

	int bias_preamp_cmd 		= 5;	//0b000101;
	int bias_feedback_cmd 		= 6;	//0b000110;
	int bias_disc_cmd 			= 7;	//0b000111;
	int bias_LVDS_cmd 			= 9;	//0b001001;
	int bias_load_cmd 			= 10;	//0b001010;
	int bias_idle_cmd 			= 8;	//0b000100;
	int bandgap_config_cmd 		= 11;	//0b001011;
	int bias_testpulse_cmd 		= 12;	//0b001100;
	int threshold_set_cmd 		= 13;	//0b001101;
	int threshold_offset_cmd 	= 29;	//0b011101;
	int bias_pixel_cmd 			= 19;	//0b010011;
	int testpulse_delay_cmd 	= 50;	//0b110010;
	int config_global_cmd 		= 30;	//0b011110;
	int readout_config_cmd 		= 31;	//0b011111;
	int programming_word_cmd 	= 2;	//0b000011;
	int TDC_config_cmd 			= 3;	//0b000011;

	int bias_preamp_data 		= 20;//75;
	int bias_feedback_data 		= 40;//100;
	int bias_disc_data 			= 1;
	int bias_LVDS_data 			= 110;//150;
	int bias_load_data 			= 20;//255;
	int bias_idle_data 			= 200;//70;
	int bandgap_config_data 	= 32;//32 to do timing measurement,/65 to inject testpulse, 64 to disable testpulse;
	int bias_testpulse_data 	= 10;
	int threshold_set_data 		= 64;//94;//Change this value to look for the baseline
	int threshold_offset_data 	= 80;//60; 
	int bias_pixel_data 		= 255;//50;
	int testpulse_delay_data 	= 63;//31;
	int config_global_data 		= 254;
	int readout_config_data 	= 255;
	int programming_word_data 	= 0;
	int TDC_config_data 		= 100;//200;

	BoardLib.ActivateConfigDevice(0, true);
	BoardLib.ActivateConfigDevice(1, true);
	BoardLib.ActivateConfigDevice(2, true);
	BoardLib.ActivateConfigDevice(3, true);
	BoardLib.ActivateConfigDevice(4, true);
	BoardLib.ActivateConfigDevice(5, true);

	BoardLib.SetVariable("TEST_OUT.SPI_START.CHIP_CFG_EN_M0", true);
	BoardLib.SetVariable("TEST_OUT.SPI_START.CHIP_CFG_EN_M1", true);
	BoardLib.SetVariable("TEST_OUT.SPI_START.CHIP_CFG_EN_M2", true);
	BoardLib.SetVariable("TEST_OUT.SPI_START.CHIP_CFG_EN_M3", true);
	BoardLib.SetVariable("TEST_OUT.SPI_START.CHIP_CFG_EN_M4", true);
	BoardLib.SetVariable("TEST_OUT.SPI_START.CHIP_CFG_EN_M5", true);

	// Start config

	for (int chip_address = 0; chip_address < 6; chip_address++)
	{

		//Super column masking

		sel = 0;

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".CHIP_ADDRESS", chip_address);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".CHIP_ADDRESS" + chip_address.ToString() + ".SC_NRESET", false); // The chip that is being configured should be reset during the whole configuration process (Masking + DAC)
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SEL", sel);
		}

		// super-column programming
		for(int super_column_nb = 0; super_column_nb < 13; super_column_nb++)
		{
			for(int module = 0; module < 6; module ++)
			{
					BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SUPER_COLUMN_NB", super_column_nb);
					BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());

					for(int asic_nb = 0; asic_nb < 2; asic_nb++)
						for(int super_pixel_nb = 7; super_pixel_nb >= 0; super_pixel_nb--)
							for(int row_nb = 0; row_nb < 16; row_nb++)
							{
								if(super_column_nb == 0 && asic_nb == 0 && super_pixel_nb == 7 && row_nb == 0) // pixel nb here is mapped correctly eg 4 = 4
								{
									string row_mask = "1111111111111111"; //the left most pixel in the string correspond to the left most pixel in the row, the right most in the string correspond to the right most pixel in the row
									BoardLib.SetVariable(	"Modules.M" + module.ToString() + ".ASIC_LSB_IF_PARALLEL_CAL" + 
															asic_nb.ToString() + ".Super_Pixel" + 
															(7-super_pixel_nb).ToString() + ".Pixel_row" + ".Pixel_row" + 
															row_nb.ToString() + ".Mask_0x", 
															odd_even_SC_masking_conversion(Convert.ToInt32(row_mask, 2), super_column_nb));	//odd_even_SC_masking_conversion takes care of converting the row_mask string according the parity of the super-column				
								}
								else
								{
									string row_mask = "1111111111111111";
									BoardLib.SetVariable(	"Modules.M" + module.ToString() + ".ASIC_LSB_IF_PARALLEL_CAL" + 
															asic_nb.ToString() + ".Super_Pixel" + 
															(7-super_pixel_nb).ToString() + ".Pixel_row" + ".Pixel_row" + 
															row_nb.ToString() + ".Mask_0x", 
															odd_even_SC_masking_conversion(Convert.ToInt32(row_mask, 2), super_column_nb));
								}
							}
			}			
			BoardLib.BoardConfigure();
			BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");
		}

		// DAC programming

		sel = 2;

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".CHIP_ADDRESS" + chip_address.ToString() + ".SC_NRESET", false);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".CHIP_ADDRESS", chip_address);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SEL", sel);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", bias_preamp_cmd);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", bias_preamp_data);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", bias_feedback_cmd);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", bias_feedback_data);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", bias_disc_cmd);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", bias_disc_data);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", bias_LVDS_cmd);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", bias_LVDS_data);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", bias_load_cmd);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", bias_load_data);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}	

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", bias_idle_cmd);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", bias_idle_data);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", bandgap_config_cmd);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", bandgap_config_data);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", bias_testpulse_cmd);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", bias_testpulse_data);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", threshold_set_cmd);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", threshold_set_data);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", threshold_offset_cmd);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", threshold_offset_data);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", bias_pixel_cmd);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", bias_pixel_data);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", testpulse_delay_cmd);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", testpulse_delay_data);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", config_global_cmd);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", config_global_data);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", readout_config_cmd);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", readout_config_data);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", TDC_config_cmd);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", TDC_config_data);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".CHIP_ADDRESS" + chip_address.ToString() + ".SC_NRESET", true);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}
	}

	BoardLib.SetVariable("Board.DirectParam.PLL_Auto_Set", true);
	BoardLib.SetDirectParameters();
	
	sel = 2;          //single SPI command
	
	for (int chip_address = 0; chip_address < 6; chip_address++)
	{
		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".CHIP_ADDRESS", chip_address);
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".CHIP_ADDRESS" + chip_address.ToString() + ".SC_NRESET", false); // The chip that is being configured should be reset during the whole configuration process (Masking + DAC)
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SEL", sel);
			
	//		BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_COMMAND", bandgap_config_cmd);
	//		BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".SPI_DATA", 65);

			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}

		BoardLib.UpdateUserParameters("TEST_OUT.SPI_START");

		for(int module = 0; module < 6; module ++)
		{
			BoardLib.SetVariable("TEST_OUT.CHIP_CONFIG_M" + module.ToString() + ".CHIP_ADDRESS" + chip_address.ToString() + ".SC_NRESET", true); // The chip that is being configured should be reset during the whole configuration process (Masking + DAC)
			BoardLib.UpdateUserParameters("TEST_OUT.CHIP_CONFIG_M" + module.ToString());
		}
	}
}