% RPG_SCENARIO.CLS - Version 0.1
% Raphaël Perret & Guillaume Godet-Bar

\NeedsTeXFormat{LaTeX2e}

\def \ClassName {rpg_scenario}
\def \fileversion {0.1}
\def \filedate {2011/01/11}
\def \fileinfo {first class of scenario}


\ProvidesClass {rpg_scenario} [\filedate \space \fileversion \space \fileinfo ]
			
\LoadClass[a4paper,12pt]{book}

\RequirePackage{/Users/raphaelperret/Documents/RPG-Manager/rpg_all_basic}

\pagestyle{headings}

% Raised Rule Command:
%  Arg 1 (Optional) - How high to raise the rule
%  Arg 2            - Thickness of the rule
\newcommand{\raisedrule}[2][0em]{\leaders\hbox{\rule[#1]{1pt}{#2}}\hfill}


%introduction environnement
\newenvironment{introduction}
{%
\newpage
}

%scene environnement
\newenvironment{scene}
{%
\newpage
}

%conclusion environnement
\newenvironment{conclusion}
{%
\newpage
}


%summary of the scene environnement -- TAG "scene_summary"
\definecolor{elementGray}{rgb}{0.92,0.93,0.94}
\makeatletter\newenvironment{scene_summary}{%
  \noindent\begin{lrbox}{\@tempboxa}
    \begin{minipage}{\columnwidth}
      \noindent\raisedrule[0.5em]{0.5pt}
      \textbf{\Large\ Summary of this scene \ }
      \raisedrule[0.5em]{0.5pt}
      \par}
    {\par\vspace{-0.6em}\rule{\columnwidth}{0.5pt}\end{minipage}
  \end{lrbox}%
\colorbox{elementGray}{\usebox{\@tempboxa}}
}\makeatother

	
% Synopsis environment
\definecolor{synopsisGray}{rgb}{0.92,0.93,0.94}
\makeatletter\newenvironment{synopsis}{%
\vspace{0.5em}
  \noindent\begin{lrbox}{\@tempboxa}
    \begin{minipage}{\columnwidth}
      \noindent\raisedrule[0.5em]{0.5pt}
      \textbf{\Large\ Synopsis\ }
      \raisedrule[0.5em]{0.5pt}
      \par}
    {\par\vspace{-0.6em}\rule{\columnwidth}{0.5pt}\end{minipage}
  \end{lrbox}%
\vspace{0.5em}
\colorbox{synopsisGray}{\usebox{\@tempboxa}}
}\makeatother

\endinput
%
