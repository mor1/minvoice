% minvoice.cls
%
% Copyright (c) 2015 Richard Mortier <mort@cantab.net>
%
% Based off a mixture of https://github.com/mkropat/dapper-invoice and
% https://github.com/treyhunner/invoices

\ProvidesClass{minvoice}[2015/04/12]
\NeedsTeXFormat{LaTeX2e}
\LoadClass[11pt]{article}

\RequirePackage{ifthen}               % page number calculations
\RequirePackage[margin=1in]{geometry} % standard geometry
\RequirePackage[hidelinks]{hyperref}  % links and metadata
\RequirePackage{soul}                 % adjusting letter spacing
\RequirePackage{etoolbox}             % "At*" hooks
\RequirePackage{fancyhdr}             % adjusting footer
\RequirePackage{longtable}            % tables
\RequirePackage{datenumber}           % calculating due date
\RequirePackage{fp}                   % invoice math
\RequirePackage{enumitem}             % customizing lists

% To handle key=value options in class definition
\RequirePackage{kvoptions}
\SetupKeyvalOptions{%
  prefix=minvoice@
}

%% currencies
\DeclareStringOption[pound]{currency}[pount]
\ProcessKeyvalOptions*

\RequirePackage{eurosym}
\ifthenelse{\equal{\minvoice@currency}{dollar}}{
  \newcommand{\currencysym}{\$}
}{}
\ifthenelse{\equal{\minvoice@currency}{euro}}{
  \newcommand{\currencysym}{\euro}
}{}
\ifthenelse{\equal{\minvoice@currency}{pound}}{
  \newcommand{\currencysym}{\textsterling}
}{}

%% Drawing the arrow
\RequirePackage{tikz}
\usetikzlibrary{calc}
\usetikzlibrary{fpu}

%% Formatting numbers
\RequirePackage{siunitx}
\sisetup{round-integer-to-decimal, group-separator={,}}

%% Fonts
\RequirePackage{fontspec}
\defaultfontfeatures{
  Ligatures = TeX,
  Path      = ./fonts/
}
\RequirePackage{fontawesome}

\IfFileExists{./fonts/OpenSans-Regular.ttf}{
  \setmainfont[
    BoldFont = OpenSans-Bold, ItalicFont = OpenSans-Italic
  ]{OpenSans-Regular}
  \setsansfont[
    BoldFont = OpenSans-Bold, ItalicFont = OpenSans-Italic
  ]{OpenSans-Regular}
}{}

%% styles
\RequirePackage{xcolor}
\definecolor{highlight}{rgb}{0.22,0.45,0.70} % light blue
\definecolor{subdued}{rgb}{0.45,0.45,0.45}   % dark grey

\def\titleStyle{\color{highlight}}

\urlstyle{sf}

%% add page numbers
\fancypagestyle{plain}{
  \renewcommand{\headrulewidth}{0pt}
  \renewcommand{\footrulewidth}{0pt}
  \fancyhf{}
}

% page numbers in footer if more than 1 page; from moderncv
\AtEndPreamble{%
  \AtBeginDocument{%
    \@ifundefined{r@lastpage}{}{%
      \ifthenelse{\pageref{lastpage}>1}{%
        \newlength{\pagenumberwidth}%
        \settowidth{\pagenumberwidth}{\thepage/\pageref{lastpage}}%
        \fancypagestyle{plain}{%
          \fancyfoot[r]
                    {\parbox[b]{\pagenumberwidth}{\thepage/\pageref{lastpage}}}%
        }%
        \pagestyle{plain}%
      }{}%
    }%
    \AtEndDocument{\label{lastpage}}%
  }%
}
\pagestyle{plain}

\setlength{\parindent}{0pt}     % disable paragraph indent

\newcommand*{\setmetadata}[3]{
  \hypersetup{
    bookmarksopen  = false,
    bookmarksdepth = 2,         % to show sections and subsections
    pdfauthor      = {#1},
    pdftitle       = {#1 --- Invoice \##2 for #3},
    pdfsubject     = {Invoice \##2},
    pdfkeywords    = {invoice, #1, #3}
  }
}

\newcommand{\me}{your~name}
\newcommand{\myaddress}{my~address}
\newcommand{\myphone}{+44 1234 567890}
\newcommand{\myemail}{me@example.com}
\newcommand{\myiban}{IBAN01234567890}
\newcommand{\myswift}{SWIFTSWIFT}

\newcommand{\invoice}{invoice-number}
\newcommand{\invoicedate}[3]{\setdate{#1}{#2}{#3}}

\newcommand{\clientcontact}{client~contact}
\newcommand{\clientname}{client~name}
\newcommand{\clientaddress}{client~address}

\newcommand*{\header}{
  \setmetadata{\me}{\invoice}{\clientname}

  {
    \centering
    \begin{tabular*}{\textwidth}{@{} l @{\extracolsep{\fill}} r @{}}
      \Large\me
      &
      \Large{\color{highlight}\em invoice} \#\invoice
      \\
      &
      \color{subdued} \thedateyear-\ifnum\value{datemonth}<10 0\fi\thedatemonth-\ifnum\value{dateday}<10 0\fi\thedateday
      \\
    \end{tabular*}
  }

  \addvspace{8ex}

  \begin{tabular}[t]{@{} p{.6\linewidth} @{} p{.4\linewidth} @{}}
    \centering

    \begin{tabular}[t]{@{} r @{\hspace{0.5em}} l}
      \infoBox{Client}{\clientname \\ \clientaddress}
      \infoBox{Contact}{\clientcontact}
      \infoBox{}{
        {\large\raisebox{.55\height}\currencysym\huge\formatcurrency
          {\getlastvalue{InvoiceTotal}} \arrowbase} \\
        {\small\color{subdued} due~\duedate}
      }
    \end{tabular}

    &

    \begin{tabular}[t]{@{} r @{\hspace{0.5em}} l}
      \infoBox{\arrowtarget Payable to}{\me \\ \myaddress}
      \infoSub{\faMobilePhone}{\small\slshape \myphone}
      \infoSub{\tiny\faEnvelope}{\small\slshape \email{\myemail}}
      \infoSub{IBAN}{\footnotesize \myiban}
      \infoSub{SWIFT}{\footnotesize \myswift}
    \end{tabular}
  \end{tabular}

  \drawarrow

  \addvspace{4ex}
}

\newcommand{\email}[1]{%
  \href{mailto:#1}{#1}%
}

\newcommand{\deadline}{30}

\newcommand{\duedate}{
  % \setdatetoday%
  \addtocounter{datenumber}{\deadline}%
  \setdatebynumber{\thedatenumber}%
  \datedate%
}

\newcommand{\infoBox}[2]{
  {\titleStyle #1}
  & \begin{minipage}[t]{.35\textwidth}
      #2
    \end{minipage} \\
  \noalign{\addvspace{2ex}}
}

\newcommand{\infoSub}[2]{
  {\color{subdued} #1}
  & \begin{minipage}[t]{.35\textwidth}
      #2
    \end{minipage} \\
  \noalign{\addvspace{2ex}}
}

%%
%% http://www.latex-community.org/forum/viewtopic.php?f=4&p=69091
%%

% this command gets written in the aux file:
\def\l@stvalue#1#2{\expandafter\xdef\csname l@#1@value\endcsname{#2}}

% this is the user command to save the last value:
\def\savelastvalue#1{%
  \AtEndDocument{
    \write\@auxout{\string\l@stvalue{#1}{\expandafter\csname #1\endcsname}}
  }
}

% this is the user command to retrieve the last value:
\def\getlastvalue#1{
  \@ifundefined{l@#1@value}
               {0}{\@nameuse{l@#1@value}}
}

% this will issue a latex warning to rerun when one of the last values has
% changed:
\AtEndDocument{
  \def\l@stvalue#1#2{%
    \def\reserved@a{#2}%
    \expandafter\ifx\csname l@#1@value\endcsname\reserved@a
    \else\@tempswatrue\fi
  }
}

%%

\gdef\InvoiceTotal{0}
\savelastvalue{InvoiceTotal}

\newcommand*{\calcamount}[1]{%
  \FPadd\gt{\InvoiceTotal}{#1}%
  \global\let\InvoiceTotal\gt%
}

\newcommand{\lineitem}[3]{
  #1
  & \begin{minipage}[t]{\linewidth}
      \begin{itemize}[leftmargin=0pt, labelsep=0.3ex, itemsep=0pt]
        \setlength{\parskip}{0pt}
        \setlength{\parsep}{0pt}
        #3
      \end{itemize}
    \end{minipage}
  & \currencysym\calcamount{#2}#2
  \\
  \noalign{\medskip}
}

\newcommand*{\itemizationHeaderStyle}[0]{\normalsize\color{highlight}}

\newenvironment{work}{
  \header
  \setlength\LTleft{0pt}
  \setlength\LTright{0pt}
  \begin{longtable}{c @{\hspace{1ex}} p{.54\linewidth} r}
    \hline\noalign{\smallskip}

    {\itemizationHeaderStyle Week Commencing}
    & {\itemizationHeaderStyle Description}
    & {\itemizationHeaderStyle Weekly Rate}
    \\

    \noalign{\smallskip}
    \hline
    \noalign{\bigskip}
    \endhead
    \noalign{\bigskip}
    \hline
    \endfoot
    \endlastfoot
}{
  \noalign{\bigskip}
  \hline
  \noalign{\medskip}

  \multicolumn{2}{r}{\itemizationHeaderStyle Balance Due}
  &
  \currencysym\formatcurrency{\InvoiceTotal}
  \\
  \end{longtable}
}

\newcommand*\@formatFraction[1]{
  \ifnum\Numerator=25 ¼\fi%
  \ifnum\Numerator=50 ½\fi%
  \ifnum\Numerator=75 ¾\fi%
}

\newcommand*\@formatHoursLeft[1]{
  \pgfmathtruncatemacro{\WholePortion}{int(#1)}%
  \pgfmathtruncatemacro{\Numerator}{100*(#1-\WholePortion)}%
  \ifnum\WholePortion=0%
  \@formatFraction{\Numerator}%
  \else%
  \WholePortion%
  \fi%
}

\newcommand*\@formatHoursRight[1]{
  \pgfmathtruncatemacro{\WholePortion}{int(#1)}%
  \pgfmathtruncatemacro{\Numerator}{100*(#1-\WholePortion)}%
  \ifnum\WholePortion=0%
  \else%
  \@formatFraction{\Numerator}%
  \fi%
}

\newcommand*{\formatcurrency}[1]{%
  \num[
    group-separator={,},
    group-minimum-digits=3,
    round-mode=places,
    round-precision=2
  ]{
    #1
  }
}

\newcommand*{\tikzmark}[1]{\tikz[overlay,remember picture] \node ({#1}) {};}
\newcommand*{\arrowbase}{\tikzmark{@p1}}
\newcommand*{\arrowtarget}{\tikzmark{@p2}}
\newcommand*{\drawarrow}{
    \tikz[overlay,remember picture] {
        \draw[->,thick,color=subdued] ($(@p1)+(0.75em,1.5ex)$) -| ($(@p2)+(-2em,0.7ex)$) -- ($(@p2)+(-0.5em,0.7ex)$);
    }
}
