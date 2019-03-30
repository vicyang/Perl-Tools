=info
    2019-03-30
    优点，比 File::Find 速度要快
    缺点，如果空目录是多级的，比如 a 目录下有 1 2 3 个空目录，
    第一次执行删除1 2 3，但是 a 会得到保留。要删除N层的“准”空目录，需要重新执行N次程序
=cut

use Cwd;
STDOUT->autoflush(1);
my $cwd = getdcwd; # Win32 current path
our $hash = {};

for my $line ( `dir /s /b` )
{
    $line=~s/\r?\n$//;
    $line=~s/^\Q$cwd\E/./;
    toStruct( $line );
}

#dd($hash);
# root => "."
deep( $hash->{"."} , "." );

# 遍历 HASH
sub deep
{
    my ($ref, $parent) = @_;
    my $count;

    for my $k ( keys %$ref )
    {
        my $path = $parent ."/". $k;
        next if -f $path;
        $count = scalar(keys %{$ref->{$k}});
        if ( $count == 0 ) {
            printf "rmdir %s\n", $path;
            rmdir $path;
        } else {
            deep( $ref->{$k}, $path );
        }
    }
}

sub toStruct
{
    my $path = shift;
    my @parts = split(/[\/\\]/, $path);
    my $ref;
    $ref = $hash;

    for my $e ( @parts )
    {
        # 如果不加判断，会不断地替换，最后只有一个路径的结构
        $ref->{$e} = {} unless exists $ref->{$e};
        $ref = $ref->{$e};
    }
}
