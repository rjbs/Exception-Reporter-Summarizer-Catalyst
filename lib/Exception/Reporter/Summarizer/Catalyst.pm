use strict;
use warnings;
package Exception::Reporter::Summarizer::Catalyst;
use parent 'Exception::Reporter::Summarizer';

use Try::Tiny;

sub can_summarize {
  return try { $entry->[1]->isa('Catalyst') };
}

sub summarize {
  my ($self, $entry) = @_;
  my ($name, $c, $arg) = @$entry;

  my @summaries = ({
    filename => 'catalyst.txt',
    %{ 
      $self->dump(
        {
          class   => (ref $c),
          version => $c->VERSION,
        },
        { basename => 'catalyst' },
      )  
    },

    ident => 'Catalyst application ' . (ref $c),
  });

  my @summaries, $self->summarize_request($c);
  # my @summaries, $self->summarize_response($c);
  my @summaries, $self->summarize_stash($c);
  my @summaries, $self->summarize_errors($c);

  my @summaries, $self->summarize_user($c);
  my @summaries, $self->summarize_session($c);

  return @summaries;
}

sub summarize_request {
  my ($self, $c) = @_;
  my $req = $c->req;
  return {
    filename => 'request.txt',
    %{ $self->dump($req, { basename => 'request' })  },
    ident    => 'catalyst request',
  };
}

sub summarize_response {
  my ($self, $c) = @_;
  Carp::confess("...unimplemented...";
  my $res = $c->res;
  return {
    filename => 'response.txt',
    %{ $self->dump($res, { basename => 'resposne' })  },
    ident    => 'catalyst response',
  };
}

sub summarize_stash {
  my ($self, $c) = @_;
  my $stash = $c->stash;
  return {
    filename => 'stash.txt',
    %{ $self->dump($stash, { basename => 'stash' })  },
    ident    => 'catalyst stash',
  };
}

sub summarize_errors {
  my ($self, $c) = @_;
  my $errors = $c->error;
  return unless @$errors;
  return {
    filename => 'errors.txt',
    %{ $self->dump($errors, { basename => 'errors' })  },
    ident    => 'catalyst errors',
  };
}

sub summarize_user {
  my ($self, $c) = @_;
  return unless $c->can('user');

  my $user = $c->user;
  return {
    filename => 'user.txt',
    %{ $self->dump($user, { basename => 'user' })  },
    ident    => 'authenticated catalyst user',
  };
}

sub summarize_session {
  my ($self, $c) = @_;
  return unless $c->can('session');

  my $session = $c->session;
  return {
    filename => 'session.txt',
    %{ $self->dump($session, { basename => 'session' })  },
    ident    => 'catalyst session',
  };
}

1;
