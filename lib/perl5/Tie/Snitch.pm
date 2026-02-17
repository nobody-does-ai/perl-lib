package Tie::Snitch;
use Tie::Array;
our(@ISA)=qw(Tie::StdArray);
#qw( TIEARRAY  FETCHSIZE STORESIZE STORE     FETCH     CLEAR     POP       PUSH      SHIFT     UNSHIFT   EXISTS    DELETE    SPLICE     );
BEGIN {
	package X;
	use Nobody::Util;
};
sub  x{
  my(@args) = map { "$_" } @_;

  X::eex([caller(1)]->[3],[@args]);
};
sub  TIEARRAY   {x(@_);  goto  \&Tie::StdArray::TIEARRAY;   };
sub  FETCHSIZE  {x(@_);  goto  \&Tie::StdArray::FETCHSIZE;  };
sub  STORESIZE  {x(@_);  goto  \&Tie::StdArray::STORESIZE;  };
sub  STORE      {x(@_);  goto  \&Tie::StdArray::STORE;      };
sub  FETCH      {x(@_);  goto  \&Tie::StdArray::FETCH;      };
sub  CLEAR      {x(@_);  goto  \&Tie::StdArray::CLEAR;      };
sub  POP        {x(@_);  goto  \&Tie::StdArray::POP;        };
sub  PUSH       {x(@_);  goto  \&Tie::StdArray::PUSH;       };
sub  SHIFT      {x(@_);  goto  \&Tie::StdArray::SHIFT;      };
sub  UNSHIFT    {x(@_);  goto  \&Tie::StdArray::UNSHIFT;    };
sub  EXISTS     {x(@_);  goto  \&Tie::StdArray::EXISTS;     };
sub  DELETE     {x(@_);  goto  \&Tie::StdArray::DELETE;     };
sub  SPLICE     {x(@_);  goto  \&Tie::StdArray::SPLICE;     };
1;


