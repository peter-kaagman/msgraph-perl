# MSGraph-Perl

Perl modules for interacting with Microsoft Graph, originally developed as the foundation of a full EduTeams provisioning system.

---

## 🚀 What is this?

MSGraph-Perl is a collection of Perl modules that provide a structured and reusable way to interact with the Microsoft Graph API.

The modules were originally built for a complete, automated EduTeams provisioning platform, prior to its replacement by a HelloID-based solution.

Today, this repository functions as both a working toolkit and a reference implementation for Graph-based automation.

---

## 🎯 Why this exists

At the time of development, no suitable abstraction layer existed for:

- Microsoft Teams provisioning
- Entra ID (Azure AD) group lifecycle management
- Structured Graph API interaction in Perl

This project provides:

- A reusable Graph abstraction layer
- Encapsulated authentication and request handling
- A structured approach to complex provisioning logic

The design emphasizes clear intent, predictable behavior, and idempotent operations.

---

## 🧠 How this relates to the current system

The original EduTeams provisioning system based on these modules has been replaced by a HelloID-driven implementation using PowerShell (PS-Modules).

However, this codebase still plays an important role:

- Reference for new PowerShell functionality
- Validation of Graph behavior and edge cases
- Rapid prototyping and ad-hoc scripting

👉 In practice: this repository acts as the conceptual and technical predecessor of the current PS-based implementation.

---

## 🔄 Relationship with PS-Modules (HelloID)

If you are working with the current EduTeams environment:

- 👉 PS-Modules = active implementation (PowerShell / HelloID)
- 👉 MSGraph-Perl = reference implementation (Perl / Graph layer)

The two share:

- Similar concepts
- Comparable function structure
- Identical underlying Graph logic

This makes MSGraph-Perl a useful source when:

- Designing new PS functions
- Debugging unexpected Graph behavior
- Understanding intent behind existing logic

---

## ⚡ Example

The base module is `MsGraph`, but for listing groups you typically use `MsGroups`, which extends it and handles token retrieval automatically during object construction.

```perl
use Config::Simple;
use FindBin;
use lib "$FindBin::Bin/lib";

use MsGroups;

my %config;
Config::Simple->import_from("$FindBin::Bin/groups.cfg", \%config)
	or die("No config: $!");

my $session = MsGroups->new(
	app_id         => $config{'APP_ID'},
	app_secret     => $config{'APP_SECRET'},
	tenant_id      => $config{'TENANT_ID'},
	login_endpoint => $config{'LOGIN_ENDPOINT'},
	graph_endpoint => $config{'GRAPH_ENDPOINT'},
);

my $groups = $session->groups_fetch();
```

If you only need to obtain a token and make lower-level Graph calls, instantiate `MsGraph` directly with the same required configuration fields.

---

## 🧩 Key features

- Microsoft Graph API abstraction
- Authentication handling
- Teams and group lifecycle operations
- Structured error handling
- Designed for automation scenarios

---

## 📘 Background & architecture

More context about EduTeams, architecture, and design evolution:

👉 https://mysite.prjv.nl/category/eduteam

---

## ⚠️ Status

This project is no longer the active provisioning implementation.

However:

- The code is stable and battle-tested
- The design patterns are still actively used
- It remains a reliable reference for new development
- Day-to-day use is more realistic from WSL/Linux than from a Windows Perl environment

---

## 📖 Documentation

Refer to the module files for implementation details and available methods.

In particular:

- `MsGraph` provides token management and generic API helpers
- `MsGroups` provides group, class, and team-related operations
- `MsUser` and `MsGroup` provide object-specific operations

---

## 🔍 Keywords

Microsoft Graph, Perl, Teams provisioning, Entra ID automation, Graph API scripting, EduTeams
