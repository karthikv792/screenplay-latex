%% screenplay.cls — Final Draft–matched LaTeX screenplay class
%% with pre-production annotation support
%%
%% Usage:
%%   \documentclass{screenplay}                  % clean shooting script
%%   \documentclass[preproduction]{screenplay}   % annotated pre-production draft
%%
%% Formatting derived from Final Draft's ParagraphSpec definitions.
%% All element indents and widths match FD exactly.
%%
%% Author: Claude (Anthropic) — 2026
%% License: MIT
%%
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{screenplay}[2026/03/16 v2.0 Screenplay class — Final Draft matched]

% ============================================================
% OPTIONS
% ============================================================

\newif\if@preproduction\@preproductionfalse
\DeclareOption{preproduction}{\@preproductiontrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass[12pt]{article}

% ============================================================
% PACKAGES
% ============================================================

\RequirePackage[
  top=1in, bottom=1in, left=1.5in, right=1in,
  headheight=15pt
]{geometry}
\RequirePackage[T1]{fontenc}
\RequirePackage{courier}
\renewcommand{\rmdefault}{pcr}
\renewcommand{\sfdefault}{pcr}
\renewcommand{\ttdefault}{pcr}
\RequirePackage{xcolor}
\RequirePackage{fancyhdr}
\RequirePackage{titlesec}
\RequirePackage{enumitem}
\RequirePackage{ifthen}
\RequirePackage{xstring}
\RequirePackage{marginnote}
\RequirePackage{etoolbox}
\RequirePackage{longtable}
\RequirePackage{booktabs}
\RequirePackage{hyperref}
\RequirePackage{environ}         % for \NewEnviron
\RequirePackage{paracol}         % for dual dialogue columns
\RequirePackage{setspace}        % line spacing
\RequirePackage{soul}            % line-breakable highlighting

% ============================================================
% PAGE STYLE — matches Final Draft header behavior
% ============================================================
% FD: Header visible (not on first page), page number top-right.
% FD: HeaderMargin = 36pt (0.5"), FooterMargin = 36pt.

\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{0pt}
\fancyhead[R]{\thepage.}
\fancypagestyle{plain}{\fancyhf{}\fancyhead[R]{\thepage.}}
\fancypagestyle{titlepage}{\fancyhf{}\renewcommand{\headrulewidth}{0pt}}

% ============================================================
% SPACING & FONT SIZE — matches Final Draft exactly
% ============================================================
% FD uses "Courier Final Draft" at 12pt — a narrower, tighter-leaded
% monospace than LaTeX's URW Courier. LaTeX's default 12pt leading
% (14.4pt) is too loose. Setting 12pt / 12.5pt leading matches FD's
% tighter line spacing and produces identical page counts.
% Works with pdflatex — no XeLaTeX required.

\singlespacing
\AtBeginDocument{\fontsize{12pt}{12.5pt}\selectfont}
\setlength{\parindent}{0pt}
\setlength{\parskip}{0pt}      % NO global parskip — elements manage their own
\raggedright                     % screenplays use left-aligned (ragged right) text
\frenchspacing                   % no extra space after periods — matches FD

% ============================================================
% FINAL DRAFT MEASUREMENTS
% ============================================================
% Derived from ParagraphSpec in the FDX file.
% All indents measured from TEXT AREA left edge (page left + 1.5").
% Text area width = 8.5" - 1.5" - 1.0" = 6.0"
%
%  Element         | Indent  | Width  | SpaceBefore
%  ----------------|---------|--------|------------
%  Scene Heading   | 0.00"   | 6.00"  | 24pt
%  Action          | 0.00"   | 6.00"  | 12pt
%  Character       | 2.00"   | 3.75"  | 12pt
%  Parenthetical   | 1.50"   | 2.50"  | 0pt
%  Dialogue        | 1.00"   | 3.50"  | 0pt
%  Transition      | 4.00"   | 1.60"  | 12pt (right-aligned)

\newlength{\fdCharIndent}    \setlength{\fdCharIndent}{2.0in}
\newlength{\fdCharWidth}     \setlength{\fdCharWidth}{3.75in}
\newlength{\fdDiaIndent}     \setlength{\fdDiaIndent}{1.0in}
\newlength{\fdDiaWidth}      \setlength{\fdDiaWidth}{3.5in}
\newlength{\fdParenIndent}   \setlength{\fdParenIndent}{1.5in}
\newlength{\fdParenWidth}    \setlength{\fdParenWidth}{2.5in}
\newlength{\fdTransIndent}   \setlength{\fdTransIndent}{4.0in}

% SpaceBefore values (FD uses 12pt = 1 line, 24pt = 2 lines at 12pt)
\newlength{\fdSlugSpace}     \setlength{\fdSlugSpace}{24pt}
\newlength{\fdActionSpace}   \setlength{\fdActionSpace}{12pt}
\newlength{\fdCharSpace}     \setlength{\fdCharSpace}{12pt}
\newlength{\fdDiaSpace}      \setlength{\fdDiaSpace}{0pt}
\newlength{\fdParenSpace}    \setlength{\fdParenSpace}{0pt}
\newlength{\fdTransSpace}    \setlength{\fdTransSpace}{12pt}

% ============================================================
% ANNOTATION COLORS
% ============================================================

\definecolor{propcolor}{HTML}{FFF176}       % Yellow
\definecolor{shotcolor}{HTML}{90CAF9}       % Blue
\definecolor{camcolor}{HTML}{CE93D8}        % Purple
\definecolor{lightingcolor}{HTML}{FFB74D}   % Orange
\definecolor{sfxcolor}{HTML}{A5D6A7}        % Green
\definecolor{vfxcolor}{HTML}{EF9A9A}        % Red
\definecolor{wardrobecolor}{HTML}{F48FB1}   % Pink
\definecolor{setnotecolor}{HTML}{80CBC4}    % Teal
\definecolor{outlinecolor}{HTML}{7D83D6}    % Lavender (outline headings)

% Revision page colors
\definecolor{revblue}{HTML}{D6EAF8}
\definecolor{revpink}{HTML}{FADBD8}
\definecolor{revyellow}{HTML}{FEF9E7}
\definecolor{revgreen}{HTML}{D5F5E3}
\definecolor{revgoldenrod}{HTML}{FDEBD0}
\definecolor{revbuff}{HTML}{FAE5D3}
\definecolor{revsalmon}{HTML}{F5B7B1}
\definecolor{revcherry}{HTML}{FADBD8}
\definecolor{revtan}{HTML}{F6DDCC}

% ============================================================
% REVISION SUPPORT
% ============================================================

\newcommand{\@revisioncolor}{white}
\newcommand{\@revisionmark}{}
\newcommand{\@revisionnumber}{}
\newcommand{\@revisiondate}{}

\newcommand{\revisioncolor}[1]{%
  \renewcommand{\@revisioncolor}{rev#1}%
}
\newcommand{\revisioninfo}[2]{%
  \renewcommand{\@revisionnumber}{#1}%
  \renewcommand{\@revisiondate}{#2}%
}
\newcommand{\revised}[1]{%
  #1\marginpar{\hfill\textbf{*}}%
}

\newif\if@hasrevcolor\@hasrevcolorfalse
\let\@orig@revisioncolor\revisioncolor
\renewcommand{\revisioncolor}[1]{%
  \@hasrevcolortrue
  \renewcommand{\@revisioncolor}{rev##1}%
}

\AddToHook{shipout/background}{%
  \if@hasrevcolor
    \put(0,-\paperheight){%
      \colorbox{\@revisioncolor}{\makebox[\paperwidth]{\vbox to \paperheight{}}}%
    }%
  \fi
}

% ============================================================
% SCENE COUNTER & SLUGLINE
% ============================================================

\newcounter{scenenumber}
\setcounter{scenenumber}{0}

\newcommand{\@currentscene}{0}

% \slugline[label]{INT./EXT.}{LOCATION}{TIME}
% FD: Bold, ALL CAPS, full width, SpaceBefore = 24pt.
% Scene numbers on both left and right margins.
\newcommand{\slugline}[4][]{%
  \ifthenelse{\equal{#1}{}}{%
    \stepcounter{scenenumber}%
    \edef\@currentscene{\thescenenumber}%
  }{%
    \renewcommand{\@currentscene}{#1}%
  }%
  \vspace{\fdSlugSpace}%
  \noindent%
  \makebox[0pt][r]{\textbf{\@currentscene}\hspace{2.5em}}%
  \textbf{\MakeUppercase{#2} \MakeUppercase{#3} --- \MakeUppercase{#4}}%
  \hfill\textbf{\@currentscene}%
  \par\nopagebreak%
}

% ============================================================
% SCREENPLAY ELEMENTS — Final Draft matched
% ============================================================

% OUTLINE HEADINGS
\newcommand{\@outlineheading}[2]{%
  \par\vspace{6pt}%
  {\noindent\color{outlinecolor}\fontfamily{qhv}\selectfont #1\textbf{#2}\par}%
  \nopagebreak%
}

\newcommand{\summary}[1]{\@outlineheading{\Huge}{#1}}
\newcommand{\outlineone}[1]{\@outlineheading{\LARGE}{#1}}
\newcommand{\outlinetwo}[1]{\@outlineheading{\Large}{#1}}
\newcommand{\outlinethree}[1]{\@outlineheading{\large}{#1}}

% ACTION — full width, SpaceBefore = 12pt
\newcommand{\action}[1]{%
  \par\vspace{\fdActionSpace}%
  {\setlength{\parindent}{0pt}\noindent #1\par}%
}

% GENERAL — same as ACTION but SpaceBefore = 0pt
\newcommand{\general}[1]{%
  \par{\setlength{\parindent}{0pt}\noindent #1\par}%
}

% CHARACTER CUE — left-aligned at 2.0" indent, 3.75" wide
% FD: Character cues are LEFT-aligned (not centered) at 3.50" from page edge.
\newcommand{\character}[2][]{%
  \par\vspace{\fdCharSpace}%
  \noindent\hspace*{\fdCharIndent}%
  \begin{minipage}[t]{\fdCharWidth}%
    \MakeUppercase{#2}%
    \ifthenelse{\equal{#1}{}}{}{ (#1)}%
  \end{minipage}%
  \par\nopagebreak%
}

% DIALOGUE — 1.0" indent, 3.5" wide, SpaceBefore = 0pt
\newcommand{\dialogue}[1]{%
  \par\nopagebreak%
  \noindent\hspace*{\fdDiaIndent}%
  \begin{minipage}[t]{\fdDiaWidth}%
    #1%
  \end{minipage}%
  \par%
}

% PARENTHETICAL — 1.5" indent, 2.5" wide, SpaceBefore = 0pt
\newcommand{\paren}[1]{%
  \par\nopagebreak%
  \noindent\hspace*{\fdParenIndent}%
  \begin{minipage}[t]{\fdParenWidth}%
    (#1)%
  \end{minipage}%
  \par\nopagebreak%
}

% TRANSITION — right-aligned, SpaceBefore = 12pt
\newcommand{\trans}[1]{%
  \par\vspace{\fdTransSpace}%
  \hfill\MakeUppercase{#1}%
  \par%
}

% DUAL DIALOGUE — side by side
\newcommand{\dualdia}[4]{%
  \par\vspace{\fdCharSpace}%
  \noindent
  \begin{minipage}[t]{0.45\linewidth}%
    {\noindent\hspace*{0.8in}\MakeUppercase{#1}\par}%
    \noindent\hspace*{0.3in}\begin{minipage}[t]{2.5in}#2\end{minipage}%
  \end{minipage}%
  \hfill
  \begin{minipage}[t]{0.45\linewidth}%
    {\noindent\hspace*{0.8in}\MakeUppercase{#3}\par}%
    \noindent\hspace*{0.3in}\begin{minipage}[t]{2.5in}#4\end{minipage}%
  \end{minipage}%
  \par%
}

% ============================================================
% TITLE PAGE
% ============================================================

\newcommand{\@screentitle}{}
\newcommand{\@screensubtitle}{}
\newcommand{\@screenauthor}{}
\newcommand{\@screencontact}{}
\newcommand{\@screendraftinfo}{}

\newcommand{\screentitle}[1]{\renewcommand{\@screentitle}{#1}}
\newcommand{\screensubtitle}[1]{\renewcommand{\@screensubtitle}{#1}}
\newcommand{\screenauthor}[1]{\renewcommand{\@screenauthor}{#1}}
\newcommand{\screencontact}[1]{\renewcommand{\@screencontact}{#1}}
\newcommand{\screendraftinfo}[1]{\renewcommand{\@screendraftinfo}{#1}}

\newcommand{\maketitlepage}{%
  \thispagestyle{titlepage}%
  \begin{center}%
    \vspace*{2.5in}%
    {\underline{\textbf{\@screentitle}}}%
    \ifthenelse{\equal{\@screensubtitle}{}}{%
      \\[2\baselineskip]%
    }{%
      \\[0.5\baselineskip]%
      \@screensubtitle\\[2\baselineskip]%
    }%
    Written by\\[0.5\baselineskip]%
    \@screenauthor%
    \ifthenelse{\equal{\@screendraftinfo}{}}{}{%
      \\[\baselineskip]%
      \@screendraftinfo%
    }%
  \end{center}%
  \vfill%
  \noindent\@screencontact%
  \newpage%
}

% ============================================================
% BREAKDOWN LOG FILE
% ============================================================

\newwrite\breakdownfile
\AtBeginDocument{%
  \if@preproduction
    \immediate\openout\breakdownfile=\jobname.breakdown%
  \fi
}
\AtEndDocument{%
  \if@preproduction
    \immediate\closeout\breakdownfile%
  \fi
}

\newcommand{\@logbreakdown}[2]{%
  \if@preproduction
    \begingroup
      \let\prop\@firstofone
      \let\wardrobe\@firstofone
      \let\shot\@firstofone
      \let\cam\@firstofone
      \let\lighting\@firstofone
      \let\sfx\@firstofone
      \let\vfx\@firstofone
      \let\setnote\@firstofone
      \let\textit\@firstofone
      \let\textbf\@firstofone
      \def\_{\string\_}%
      \immediate\write\breakdownfile{%
        \string\breakdownentry{\@currentscene}{#1}{#2}%
      }%
    \endgroup
  \fi
}

% ============================================================
% ANNOTATION COMMANDS
% ============================================================

\newcommand{\@setupinnerannot}{%
  \def\prop##1{##1\textsuperscript{\,\tiny\sffamily P}}%
  \def\wardrobe##1{##1\textsuperscript{\,\tiny\sffamily W}}%
  \def\shot##1{##1\textsuperscript{\,\tiny\sffamily S}}%
  \def\cam##1{##1\textsuperscript{\,\tiny\sffamily C}}%
  \def\lighting##1{##1\textsuperscript{\,\tiny\sffamily L}}%
  \def\sfx##1{##1\textsuperscript{\,\tiny\sffamily X}}%
  \def\vfx##1{##1\textsuperscript{\,\tiny\sffamily V}}%
  \def\setnote##1{##1\textsuperscript{\,\tiny\sffamily D}}%
}

\newcommand{\prop}[1]{%
  \if@preproduction
    \@logbreakdown{PROP}{#1}%
    \begingroup\@setupinnerannot
    {\sethlcolor{propcolor}\hl{#1}}\textsuperscript{\,\tiny\sffamily P}%
    \endgroup
  \else #1\fi
}

\newcommand{\wardrobe}[1]{%
  \if@preproduction
    \@logbreakdown{WARDROBE}{#1}%
    \begingroup\@setupinnerannot
    {\sethlcolor{wardrobecolor}\hl{#1}}\textsuperscript{\,\tiny\sffamily W}%
    \endgroup
  \else #1\fi
}

\newcommand{\shot}[1]{%
  \if@preproduction
    \@logbreakdown{SHOT}{#1}%
    \begingroup\@setupinnerannot
    {\sethlcolor{shotcolor}\hl{#1}}\textsuperscript{\,\tiny\sffamily S}%
    \endgroup
  \else \unskip\ignorespaces\fi
}

\newcommand{\cam}[1]{%
  \if@preproduction
    \@logbreakdown{CAM}{#1}%
    \begingroup\@setupinnerannot
    {\sethlcolor{camcolor}\hl{#1}}\textsuperscript{\,\tiny\sffamily C}%
    \endgroup
  \else \unskip\ignorespaces\fi
}

\newcommand{\lighting}[1]{%
  \if@preproduction
    \@logbreakdown{LIGHTING}{#1}%
    \begingroup\@setupinnerannot
    {\sethlcolor{lightingcolor}\hl{#1}}\textsuperscript{\,\tiny\sffamily L}%
    \endgroup
  \else \unskip\ignorespaces\fi
}

\newcommand{\sfx}[1]{%
  \if@preproduction
    \@logbreakdown{SFX}{#1}%
    \begingroup\@setupinnerannot
    {\sethlcolor{sfxcolor}\hl{#1}}\textsuperscript{\,\tiny\sffamily X}%
    \endgroup
  \else \unskip\ignorespaces\fi
}

\newcommand{\vfx}[1]{%
  \if@preproduction
    \@logbreakdown{VFX}{#1}%
    \begingroup\@setupinnerannot
    {\sethlcolor{vfxcolor}\hl{#1}}\textsuperscript{\,\tiny\sffamily V}%
    \endgroup
  \else \unskip\ignorespaces\fi
}

\newcommand{\setnote}[1]{%
  \if@preproduction
    \@logbreakdown{SET}{#1}%
    \begingroup\@setupinnerannot
    {\sethlcolor{setnotecolor}\hl{#1}}\textsuperscript{\,\tiny\sffamily D}%
    \endgroup
  \else \unskip\ignorespaces\fi
}

\soulregister\prop{1}
\soulregister\wardrobe{1}
\soulregister\shot{1}
\soulregister\cam{1}
\soulregister\lighting{1}
\soulregister\sfx{1}
\soulregister\vfx{1}
\soulregister\setnote{1}

% ============================================================
% PRE-PRODUCTION LEGEND
% ============================================================

\newcommand{\preprodlegend}{%
  \if@preproduction
    \par\noindent\textbf{PRE-PRODUCTION ANNOTATION LEGEND}\par
    \vspace{0.5\baselineskip}
    \noindent
    \begin{tabular}{@{}llll@{}}
      \colorbox{propcolor}{\strut\,\textsuperscript{\tiny\sffamily P}\,Prop\,}
      & \colorbox{shotcolor}{\strut\,\textsuperscript{\tiny\sffamily S}\,Shot\,}
      & \colorbox{camcolor}{\strut\,\textsuperscript{\tiny\sffamily C}\,Camera\,}
      & \colorbox{lightingcolor}{\strut\,\textsuperscript{\tiny\sffamily L}\,Lighting\,} \\[4pt]
      \colorbox{sfxcolor}{\strut\,\textsuperscript{\tiny\sffamily X}\,SFX\,}
      & \colorbox{vfxcolor}{\strut\,\textsuperscript{\tiny\sffamily V}\,VFX\,}
      & \colorbox{wardrobecolor}{\strut\,\textsuperscript{\tiny\sffamily W}\,Wardrobe\,}
      & \colorbox{setnotecolor}{\strut\,\textsuperscript{\tiny\sffamily D}\,Set Note\,} \\
    \end{tabular}
    \par\vspace{\baselineskip}
    \noindent\begin{sloppypar}\textit{Highlighted annotations are visible in
    pre-production mode only. Items marked P and W preserve their text in
    clean mode; all others are removed.}\end{sloppypar}
    \par\vspace{\baselineskip}
    \hrule
    \vspace{\baselineskip}
  \fi
}

% ============================================================
% BREAKDOWN TABLE
% ============================================================

\newcommand{\printbreakdown}{%
  \if@preproduction
    \newpage
    \begin{center}\textbf{\large SCENE BREAKDOWN}\end{center}
    \vspace{\baselineskip}
    {\small
      \def\breakdownentry##1##2##3{##1 & ##2 & ##3 \\}%
      \noindent
      \begin{longtable}{@{}p{0.8cm}p{2cm}p{10cm}@{}}
        \toprule
        \textbf{Sc.} & \textbf{Category} & \textbf{Item} \\
        \midrule\endhead\bottomrule\endfoot
        \IfFileExists{\jobname.breakdown}{\input{\jobname.breakdown}}{}%
      \end{longtable}
    }%
  \fi
}

\newcommand{\printbreakdownraw}{%
  \if@preproduction
    \newpage
    \begin{center}\textbf{\large SCENE BREAKDOWN}\end{center}
    \vspace{\baselineskip}
    \noindent\begin{sloppypar}\textit{%
      The full machine-readable breakdown is in
      \texttt{\jobname.breakdown}. Below is a formatted summary.%
    }\end{sloppypar}
    \vspace{\baselineskip}
    {\small
      \let\prop\@firstofone  \let\wardrobe\@firstofone
      \let\shot\@firstofone  \let\cam\@firstofone
      \let\lighting\@firstofone \let\sfx\@firstofone
      \let\vfx\@firstofone   \let\setnote\@firstofone
      \let\textit\@firstofone
      \def\breakdownentry##1##2##3{%
        \par\noindent\textbf{Sc.~##1} \quad [\textbf{##2}] \quad ##3%
      }%
      \IfFileExists{\jobname.breakdown}{\input{\jobname.breakdown}}{%
        \textit{(No breakdown data --- compile twice.)}%
      }%
    }
  \fi
}

% ============================================================
% CONVENIENCE: CONTINUED / MORE
% ============================================================

\newcommand{\continued}{%
  \par\vfill\noindent\MakeUppercase{(continued)}\newpage%
  \noindent\MakeUppercase{continued:}\par%
}

\newcommand{\moremark}{%
  \par\begin{center}(MORE)\end{center}%
}

% ============================================================
% NOTES / COMMENTS
% ============================================================

\newcommand{\scriptnote}[1]{%
  \if@preproduction
    \par\noindent
    \fcolorbox{black}{yellow!20}{\parbox{\dimexpr\linewidth-2\fboxsep-2\fboxrule}{%
      \small\textbf{NOTE:} #1%
    }}%
    \par%
  \fi
}

% ============================================================
% HYPERREF CONFIG
% ============================================================

\hypersetup{colorlinks=false, pdfborder={0 0 0}}

\endinput
