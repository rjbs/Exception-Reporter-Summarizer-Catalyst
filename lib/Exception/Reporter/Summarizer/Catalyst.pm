use strict;
use warnings;
package Exception::Reporter::Summarizer::Catalyst;
use parent 'Exception::Reporter::Summarizer';
# ABSTRACT: a summarizer for Catalyst applications

use Try::Tiny;

sub can_summarize {
  my ($self, $entry) = @_;
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

  push @summaries, $self->summarize_request($c);
  # push @summaries, $self->summarize_response($c);
  push @summaries, $self->summarize_stash($c);
  push @summaries, $self->summarize_errors($c);

  push @summaries, $self->summarize_user($c);
  push @summaries, $self->summarize_session($c);

  return @summaries;
}

sub summarize_request {
  my ($self, $c) = @_;
  my $req = $c->req;

  my $cookie_hash = $req->cookies;
  my %cookie_str = map {; $_ => $cookie_hash->{$_}->value } keys %$cookie_hash;

  my $to_dump = {
    action           => $req->action,
    address          => $req->address,
    arguments        => $req->arguments,
    body_parameters  => $req->body_parameters,
    cookies          => \%cookie_str,
    headers          => $req->headers,
    hostname         => $req->hostname,
    method           => $req->get,
    query_parameters => $req->query_parameters,
    uri              => "" . $req->uri,
    uploads          => $req->uploads,
  };

  return {
    filename => 'request.txt',
    %{ $self->dump($to_dump, { basename => 'request' })  },
    ident    => 'catalyst request',
  };
}

sub summarize_response {
  my ($self, $c) = @_;
  Carp::confess("...unimplemented...");
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
