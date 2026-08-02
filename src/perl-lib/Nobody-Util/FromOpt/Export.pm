package Nobody::Export;
use Nobody::PP;
BEGIN { print @Nobody::PP::EXPORT; }
sub import {
  say STDERR "import".pp(@_);
};

1;
