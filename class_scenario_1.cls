\NeedsTeXFormat{LaTeX2e}

\def \ClassName {class_scenario_1}
\def \fileversion {1.0}
\def \filedate {2011/01/11}
\def \fileinfo {first class of scenario}


\ProvidesClass {/Users/raphaelperret/Documents/RPG-Manager/class_scenario_1} [\filedate \space \fileversion \space \fileinfo ]
			
\LoadClass[a4paper,french,12pt]{book}

\author{Raphael Perret \and Guillaume Godet-Bar}

\RequirePackage{/Users/raphaelperret/Documents/RPG-Manager/pack_all_basic}

%insertion command for element of background
\newcommand\background[1]
	{
	\emph{#1}
	}

\endinput