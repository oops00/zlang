/*

	About: property lang system
	Author: ziggi

*/

#if defined _zlang_included
	#endinput
#endif

#define _zlang_included
#pragma library zlang


#define MAX_TEXT_ENTRIES       1024

#define MAX_MULTI_VAR_COUNT    10

#define MAX_LANG_VAR_STRING    48
#define MAX_LANG_VALUE_STRING  128
#define MAX_LANG_MULTI_STRING  (MAX_LANG_VALUE_STRING * MAX_MULTI_VAR_COUNT)


#define _(%0) Lang_GetText(#%0)
#define _m(%0) Lang_GetMultiText(#%0)


stock Lang_LoadText(filename[])
{
	new File:flang = fopen(filename, io_read);
	if (!flang) {
		printf("Error: no such language file '%s'", filename);
		return 0;
	}
	
	new
		i,
		sep_pos,
		varname[MAX_LANG_VAR_STRING],
		string[MAX_LANG_VALUE_STRING + MAX_LANG_VAR_STRING];

	while (fread(flang, string, sizeof(string))) {
		if (string[0] == '\0' || (string[0] == '/' && string[1] == '/')) {
			continue;
		}
		
		sep_pos = -1;
		for (i = 0; string[i] >= ' '; i++) {
			if (sep_pos == -1) {
				if (string[i] == ' ' && string[i + 1] == '=' && string[i + 2] == ' ') {
					strmid(varname, string, 0, i);
					sep_pos = i;
				}
			} else if (string[i] == '\\') {
				switch (string[i + 1]) {
					case 'n': {
						strdel(string, i, i + 1);
						string[i] = '\n';
					}
					case 't': {
						strdel(string, i, i + 1);
						string[i] = '\t';
					}
					case '%': {
						strdel(string, i, i + 1);
						strins(string, "%", i);
					}
					case 's': {
						strdel(string, i, i + 1);
						string[i] = ' ';
					}
					case '\\': {
						strdel(string, i, i + 1);
						string[i] = '\\';
					}
				}
			}
		}

		if (sep_pos != -1) {
			string[i] = '\0';
			Lang_SetText(varname, string[sep_pos + 3]);
		}
	}

	fclose(flang);
	return 1;
}

stock Lang_SetText(varname[], value[])
{
	if (isnull(varname)) {
		return 0;	
	}
	SetSVarString(varname, value);
	return 1;
}

stock Lang_GetText(varname[])
{
	new string[MAX_LANG_VALUE_STRING];
	if (!isnull(varname)) {
		new length = GetSVarString(varname, string, sizeof(string));
		FixAscii(string);

		if (length == 0) {
			strcat(string, "Error: lang value ");
			strcat(string, varname);
			strcat(string, " not found.");
		}
	} else {
		strcat(string, "Error: lang varname is null");
	}
	return string;
}

stock Lang_GetMultiText(varname[])
{
	new string[MAX_LANG_MULTI_STRING];
	if (!isnull(varname)) {
		new
			length,
			property_value[MAX_LANG_VALUE_STRING],
			property_name[MAX_LANG_VAR_STRING + 6];

		for (new i = 0; i < MAX_MULTI_VAR_COUNT; i++) {
			format(property_name, sizeof(property_name), "%s_%d", varname, i);
			length = GetSVarString(property_name, property_value, sizeof(property_value));
			
			if (length != 0) {
				FixAscii(property_value);
				strcat(string, property_value);
			} else {
				if (i == 0) {
					strcat(string, "Error: multi lang value ");
					strcat(string, varname);
					strcat(string, " not found.");
				}
				break;
			}
		}
	} else {
		string = "Error: multi lang varname is null";
	}
	return string;
}

stock Lang_DeleteText(varname[])
{
	if (!isnull(varname)) {
		return DeleteSVar(varname);
	}
	return 0;
}