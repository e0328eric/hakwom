%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Exam Package for LaTeX
% Author : Sungbae Jeong (Almagest)
% Release Date : 2020/03/30
% Version : 2.01
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LaTeX format and Define class name
\NeedsTeXFormat{LaTeX2e}
\RequirePackage{expl3, xparse, l3keys2e}
\ProvidesExplClass {hakwon} {2022/04/07} {2.01} {Copywrite to Almagest}

\bool_new:N \g_one_col_bool

\keys_define:nn {hakwon-main-options}
{
    onecol .bool_set:N = \g_one_col_bool,
}
\ProcessKeysOptions{hakwon-main-options}

\bool_if:NTF \g_one_col_bool
{%
    \LoadClass[a4paper]{article}
}
{%
    \LoadClass[a4paper, twocolumn]{article}
}

% Include Packages
\RequirePackage{luaotfload}
\RequirePackage{fontspec}
\RequirePackage{coprime-math}
\RequirePackage{kotex}
\RequirePackage[normalem]{ulem}
\RequirePackage{iftex}
\RequirePackage{dhucs-enumitem}
\ExplSyntaxOff
\RequirePackage{tikz}
\usetikzlibrary{intersections, calc, arrows.meta}
\RequirePackage{tkz-euclide}
\ExplSyntaxOn

% Font Settings
\newfontfamily{\@notosans}{Noto Sans KR}[BoldFont=* Bold]
\newfontfamily{\@notoserif}{Noto Serif KR}[BoldFont=* Bold]

\def\titlefont{\bfseries\fontsize{21pt}{25.2pt}\selectfont\@notosans}
\def\subtitlefont{\bfseries\fontsize{15pt}{18pt}\selectfont\@notosans}
\def\titlewarningfont{\bfseries\fontsize{18pt}{21.6pt}\selectfont\@notosans}
\def\titleexplainfont{\fontsize{10pt}{12pt}\selectfont\@notosans}
\def\mainfont{\fontsize{10pt}{12pt}\selectfont\@notoserif}
\def\headfont{\bfseries\fontsize{10pt}{12pt}\selectfont\@notosans}
\def\footfont{\bfseries\fontsize{10pt}{12pt}\selectfont\@notosans}
\def\explainfont{\fontsize{8.5pt}{10.2pt}\selectfont\@notoserif}
\def\sansfont{\fontsize{10pt}{12pt}\selectfont\@notosans}
\def\seriffont{\fontsize{10pt}{12pt}\selectfont\@notoserif}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Defining Basic Commands and Variables  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define Image relative code inside Luatex
\let\pdfximage\saveimageresource
\let\pdflastximage\lastsavedimageresourceindex
\let\pdflastximagepages\lastsavedimageresourcepages
\let\pdfrefximage\useimageresource

% Total score constant in lua code
\directlua{scorecnt = 0}

% Constants
\newif\ifish@mew@rk \newif\ifsubpr@blemused \newif\ifanswershown \newif\ifansdisplaysh@on
\newif\ifnotch@ngedims \newif\ifd@cumentends
\newbox\titleb@x \newbox\leftb@x \newbox\headb@xeven \newbox\headb@xodd
\newtoks\@maintitle \newtoks\@subtitle
\newcount\questi@ncnt \newcount\subquesti@ncnt \newcount\@timelimit
\newdimen\fr@dimen
\notch@ngedimstrue

\ior_new:N \g_sc@re_ior
\iow_new:N \g_sc@re_iow

% Floating point for score
\fp_new:N \g_sc@re_fp

\let\homework=\ish@mew@rktrue
\let\showanswer=\answershowntrue

\bool_if:NTF \g_one_col_bool
{
    \setlength{\textheight}{\pageheight}
    \setlength{\textwidth}{\pagewidth}
    \addtolength{\textheight}{-6truecm}
    \addtolength{\textwidth}{-4truecm}
    \setlength{\voffset}{-1.3truecm}
    \setlength{\hoffset}{-2.45truecm}
    \parindent=0pt \baselineskip=13pt plus 1ex minus 1ex
    \lineskip=3pt \lineskiplimit=3pt
}
{
    \setlength{\columnsep}{20pt}
    \setlength{\columnseprule}{1pt}
    \setlength{\textheight}{647pt}
    \setlength{\textwidth}{520pt}
    \setlength{\voffset}{-0.25in}
    \setlength{\hoffset}{-0.42in}
}

\parindent=0pt \baselineskip=15pt plus1ex minus1ex
\lineskip=5pt \lineskiplimit=5pt

% Boxed
\def\boxit#1#2#3{\vbox{\hrule height#1\hbox to\hsize{\vrule width#1\kern#2pt\hss\vbox{\vskip#2pt #3 \vskip#2pt}%
\hss\kern#2pt\vrule width#1}\hrule height#1}}

%%%%%%%%%%%%%%%%%%%%
%  Math Utilities  %
%%%%%%%%%%%%%%%%%%%%
% Math Floating Point Command
\def\fr#1{\begingroup
\setbox0=\hbox{#1}
\advance\fr@dimen by \ht0
\advance\fr@dimen by -.6pt
\ooalign{\raise\fr@dimen\hbox to\wd0{\hss\fontsize{15}{5}\selectfont$\cdot$\hss}\cr$#1$\cr}
\endgroup}

% Math Segment Command
\def\seg#1{\overline{\rm{#1}}}

% Question and Score Command
\outer\def\question{\ifsubpr@blemused \subquesti@ncnt=0\fi
\subpr@blemusedfalse
\par\vfill
\global\advance\questi@ncnt by 1
{\bfseries\the\questi@ncnt.}\enskip\ignorespaces}
\def\subquestion{\ifsubpr@blemused \par\vfill
\else\par\vskip5pt
\fi
\subpr@blemusedtrue
\global\advance\subquesti@ncnt by 1
{(\the\subquesti@ncnt)}\enskip\ignorespaces}
\def\score#1;{\fp_add:Nn \g_sc@re_fp {#1}
{\unskip\nobreak\hfil\penalty50\hskip2em\hbox{}\nobreak\hfil[\fp_to_decimal:n {#1}점]
\parfillskip=0pt \finalhyphendemerits=0 \par}}
\def\subscore#1;{{\unskip\nobreak\hfil\penalty50\hskip2em\hbox{}\nobreak\hfil({#1}점)
\parfillskip=0pt \finalhyphendemerits=0 \par}}

\let\q=\question
\let\sq=\subquestion

% Display style default command
\def\defaultdisplay{\everymath={\displaystyle}}

% Numbering
\def\cn#1{\ifnum #1<1
\hbox{\ooalign{$\mathchar"020D$\cr\hidewidth\lower.1ex\hbox{$?$}\hidewidth\cr}}
\else\ifnum #1<10
\hbox{\ooalign{$\mathchar"020D$\cr\hidewidth\lower.1ex\hbox{$#1$}\hidewidth\cr}}
\else
\hbox{\ooalign{$\mathchar"020D$\cr\hidewidth\lower.1ex\hbox{$?$}\hidewidth\cr}}
\fi\fi}
\let\binomial=\choose
\outer\def\choose#1{\par\nobreak\kern5pt\nobreak\begingroup\def\\{\cr}\vbox{\halign to\hsize{&\tabskip=0pt\relax
\cn{##}\kern3pt&##\hfil\tabskip=0pt plus1fil\crcr#1\crcr}}\endgroup}
\outer\def\mchoose#1{\par\nobreak\kern5pt\nobreak\begingroup\def\\{\cr}\vbox{\halign to\hsize{&\tabskip=0pt\relax
\cn{##}\kern3pt&$##$\hfil\tabskip=0pt plus1fil\crcr#1\crcr}}\endgroup}
\outer\def\dchoose#1{\par\nobreak\kern5pt\nobreak\begingroup\def\\{\cr}\vbox{\halign to\hsize{&\tabskip=0pt\relax
\cn{##}\kern3pt&$\displaystyle##$\hfil\tabskip=0pt plus1fil\crcr#1\crcr}}\endgroup}

% Korean Itemize
\def\koenum#1{\ifcase#1 (???)\or%
(가)\or(나)\or(다)\or(라)\or(마)\or(바)\or(사)\or(아)\or%
(자)\or(차)\or(카)\or(타)\or(파)\or(하)\else(???)\fi\enskip\ignorespaces}

% ExplainBox
\newsavebox{\explainb@x}
\NewDocumentEnvironment{explain}{}{\begin{lrbox}{\explainb@x}\begin{minipage}{0.93\hsize}\vskip3pt}
{\vskip5pt\end{minipage}\end{lrbox}\begin{center}\framebox[\hsize]{\usebox{\explainb@x}}\end{center}}

% Answer Part
\definecolor{answer}{cmyk}{0,1,1,0}
\def\answer#1{\ifanswershown\par\null\hfill{\color{answer}\bfseries Ans\ :\ {#1}}\fi}
\newsavebox{\answerb@x}
\NewDocumentEnvironment{longanswer}{}{\begin{lrbox}{\answerb@x}\begin{minipage}{\hsize}\renewcommand{\baselinestretch}{1.8}\color{answer}\bf{Ans : }}
{\end{minipage}\end{lrbox}\ifanswershown\vbox to0pt{\usebox{\answerb@x}\vss}\fi}

% Define Main title, Sub title and Timelimit
\def\maintitle#1{\@maintitle{#1}}
\def\subtitle#1{\@subtitle{#1}}
\def\timelimit#1{\@timelimit#1}

\let\subq\subquestion
\def\segment#1{\overline{\text{#1}}}
\let\oldtriangle\triangle
\let\oldangle\angle
\def\angle#1{\oldangle\text{#1}}
\def\triangle#1{\oldtriangle\text{#1}}

% Evaluation Maths
\NewDocumentCommand{\eval}{m}{
  \fp_to_decimal:n {#1}
}

% PageNumber
\def\pagenum{\tikz{%
\path (11.5pt,15.3pt) node {\thepage};
\path (34.5pt,7.67pt) node {\tl_use:N \t@talpage};
\draw[thick] (0,0) rectangle (46pt,23pt);
\draw[thick] (0,0) -- (46pt,23pt);
}}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Main Implementation Part  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\bool_if:NTF \g_one_col_bool
{%
    \AtBeginDocument{
        \file_if_exist:nTF {\jobname.tdt}
        {
            \ior_open:Nn \g_sc@re_ior {\jobname.tdt}
            \ior_get:NN \g_sc@re_ior \t@talsc@re
            \ior_get:NN \g_sc@re_ior \t@talpage
            \ior_close:N \g_sc@re_ior
        }
        {
            \tl_gset:Nn \t@talsc@re {0}
            \tl_gset:Nn \t@talpage {0}
        }
        \thispagestyle{empty}
        \hbox{}
        \vskip 0pt plus 1filll
        \centerline{\titlefont\the\maintitle}
        \vskip 0.5pc
        \centerline{\subtitlefont\the\subtitle}
        \vskip 2pc
        \boxit{1pt}{9}{\hbox to0.95\hsize{\headfont 성명: \hss}}
        \vskip 5pt
        \boxit{1pt}{9}{%
            \vskip3pt
            \titleexplainfont
            \begin{itemize}
                \item 총점은\ {\bfseries\t@talsc@re 점}이며,\ 제한시간은\ {\bfseries\the\timelimit 분}입니다.
                \item 시험지는\ 표지\ 제외\ 총\ {\bfseries\t@talpage 페이지}입니다.
                \item 증명이\ 아닌\ 정답이\ 있는\ 문제는\ 정답을\ {\bfseries 알아볼\ 수\ 있게}\ 표시하시오.
                \item 풀이과정은\ 각\ 문제\ 밑에\ 서술형으로\ 쓰시면\ 됩니다.
                \item 풀이과정은\ {\bfseries 정자로}\ 쓰십시오.
                \item 풀이과정을\ 쓸\ 때에\ {\bfseries 여백이\ 부족}한\ 경우,\ 감독관에게\ 여분의\ 종이를\ 요구할\ 수\ 있습니다.
                \item {\bfseries 컨닝}\ 혹은\ {\bfseries 분위기를\ 흐리는\ 자}는\ 성적이\ {\bfseries 0점}처리\ 됩니다.
            \end{itemize}
        }
        \vskip 5pt
        \boxit{1pt}{9}{%
            \spaceskip=0.7em plus 1ex minus 1ex
            \hbox to0.95\hsize{\hss\titlewarningfont\# 시험이\ 시작되기\ 전\ 까지\ 페이지를\ 넘기지\ 마시오\#\hss}
        }
        \vskip 0pt plus 1filll
        \eject
        \thispagestyle{empty}\hbox{}\vfill\eject
        \def\nextq{%
            \ifd@cumentends
            \else
            \ifnum\count0=1
                \def\@evenhead{}
            \else\ifodd\count0
                \def\@oddhead{\hfil\vbox to\headheight{\hbox to\hsize{\headfont\the\@maintitle\hfil\the\@subtitle}\kern1ex\hrule height 1pt\vss}\hfil}
                \def\@evenhead{\hfil\vbox to\headheight{\hbox to\hsize{\headfont\the\@maintitle\hfil\the\@subtitle}\kern1ex\hrule height 1pt\vss}\hfil}
            \else
                \def\@oddhead{\hfil\vbox to\headheight{\hbox to\hsize{\headfont\the\@subtitle\hfil\the\@maintitle}\kern1ex\hrule height 1pt\vss}\hfil}
                \def\@evenhead{\hfil\vbox to\headheight{\hbox to\hsize{\headfont\the\@maintitle\hfil\the\@subtitle}\kern1ex\hrule height 1pt\vss}\hfil}
            \fi\fi\fi
        \vfill\newpage
        }
        \pagestyle{plain}
        {\global\advance\count0 by -2}
        \def\@oddfoot{\hfil\pagenum\hfil}
        \let\@evenfoot\@oddfoot
        \ifnum\count0=1
        \hbox{}
        \vskip-2cm
        \centerline{\titlefont\the\@maintitle}
        \vskip 0.5pc
        \centerline{\subtitlefont\the\@subtitle}
        \vskip 1pc
        \hrule height1.5pt
        \vskip 1pc plus -1fill
        \fi
        \mainfont
    }
}
{%
    \AtBeginDocument{
        \file_if_exist:nTF {\jobname.tdt}
        {
            \ior_open:Nn \g_sc@re_ior {\jobname.tdt}
            \ior_get:NN \g_sc@re_ior \t@talsc@re
            \ior_get:NN \g_sc@re_ior \t@talpage
            \ior_close:N \g_sc@re_ior
        }
        {
            \tl_gset:Nn \t@talsc@re {0}
            \tl_gset:Nn \t@talpage {0}
        }
        \ifish@mew@rk
        \setbox0=\hbox to\textwidth{\headfont 성명\ :\ \leaders\hrule\hskip2.5cm\hfil}
        \else
        \setbox0=\hbox to\textwidth{\headfont 성명\ :\ \leaders\hrule\hskip2.5cm\hfil
        \vbox{\halign{&\hfil\headfont#\cr 총점\ :\ { \tl_use:N \t@talsc@re }\unskip 점\cr 제한\ 시간\ :\ \the\@timelimit 분\cr}}}
        \fi
        \ht0=0pt
        \setbox\titleb@x=\hbox to\textwidth{\hfil\vbox{\halign{&\hfil#\hfil\cr
        \titlefont\the\@maintitle\cr\headfont\the\@subtitle\cr}}\hfil}
        \setlength{\headheight}{\ht\titleb@x}
        \setlength{\headsep}{0.8cm}
        \def\@oddhead{\vbox to\headheight{\box\titleb@x\box0\vskip0.65pc\hrule height1pt\vskip1pc\vss}}
        \def\@evenhead{\hfil\vbox to\headheight{\hbox to\textwidth{\headfont\the\@subtitle\hfil\the\@maintitle}\kern1ex\hrule height 1pt\vss}\hfil}
        \def\@oddfoot{\hfil\pagenum\hfil}
        \let\@evenfoot\@oddfoot
        \def\breakcolumn{
            \vfill\eject
            \ifnotch@ngedims
            \ifnum\count0>1
            \setlength{\voffset}{0pt}
            \setlength{\topmargin}{0pt}
            \setlength{\headheight}{12pt}
            \setlength{\headsep}{17pt}
            \notch@ngedimsfalse
                \def\@oddhead{\hfil\vbox to\headheight{\hbox to\textwidth{\headfont\the\@maintitle\hfil\the\@subtitle}\kern1ex\hrule height 1pt\vss}\hfil}
            \fi\fi
        }
        \def\nextq{\breakcolumn\hbox{}\breakcolumn}
        \mainfont
    }
}

\bool_if:NTF \g_one_col_bool
{%
    \AtEndDocument{%
        \d@cumentendstrue
        \nextq
        {\global\advance\count0 by -1}
        \pagestyle{empty}
        \ifodd\count0\else\hbox{}\nextq{\global\advance\count0 by -1}\fi
        \hbox{}
        \vskip 0pt plus 1filll
        \boxit{1pt}{9}{%
            \spaceskip=0.7em plus 1ex minus 1ex
            \hbox to0.95\hsize{\hss\titlewarningfont\# 시험이\ 시작되기\ 전\ 까지\ 페이지를\ 넘기지\ 마시오\#\hss}
        }
        \vskip 0pt plus 1filll
        \iow_open:Nn \g_sc@re_iow {\jobname.tdt}
        \iow_now:Nx \g_sc@re_iow {\fp_use:N \g_sc@re_fp}
        \iow_now:Nx \g_sc@re_iow {\thepage}
        \iow_close:N \g_sc@re_iow
    }
}
{%
    \AtEndDocument{%
        \iow_open:Nn \g_sc@re_iow {\jobname.tdt}
        \iow_now:Nx \g_sc@re_iow {\fp_use:N \g_sc@re_fp}
        \iow_now:Nx \g_sc@re_iow {\thepage}
        \iow_close:N \g_sc@re_iow
    }
}
