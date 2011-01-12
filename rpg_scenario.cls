\NeedsTeXFormat{LaTeX2e}

\def \ClassName {rpg_scenario}
\def \fileversion {1.0}
\def \filedate {2011/01/11}
\def \fileinfo {first class of scenario}


\ProvidesClass {rpg_scenario} [\filedate \space \fileversion \space \fileinfo ]
			
\LoadClass[a4paper,12pt]{book}

\RequirePackage{rpg_all_basic}

%insertion command for element of background
\newcommand\background[1]
	{
	\itshape{#1}
	}
	
\endinput
