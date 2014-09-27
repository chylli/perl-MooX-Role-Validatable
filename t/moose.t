use strict;
use Test::More;

BEGIN {
    eval 'require Moose';
    plan skip_all => 'Moose is required to test.' if $@;
}

{
    package MyClass;

    use Moose;
    with 'MooX::Role::Validatable';

    has 'attr1' => (is => 'rw', lazy_build => 1);

    sub _build_attr1 {
        my $self = shift;

        # Note initialization errors
        $self->add_errors( {
            message => 'Error: blabla',
            message_to_client => 'Something is wrong!'
        } ) if 'blabla';
    }

    sub _validate_some_other_errors { # _validate_*
        my $self = shift;

        my @errors;
        push @errors, {
            message => '...',
            message_to_client => '...',
        };
        return @errors;
    }

    sub _validate_other {
        return;
    }

    no Moose;
}

## test MyClass
my $ex = MyClass->new;
my $validation_methods = $ex->validation_methods;
ok(grep { $_ eq '_validate_some_other_errors' } @$validation_methods);
ok(grep { $_ eq '_validate_other' } @$validation_methods);

done_testing;

1;