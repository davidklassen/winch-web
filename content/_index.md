---
title: Dead simple server configuration tool
description: winch is a server configuration tool. It describes the desired state of your servers in declarative YAML and provides commands to manage that state.
bookToC: false
---

{{< hero >}}

# Dead simple server configuration tool. {anchor=false}

winch is a server configuration tool. It describes the desired state
of your servers in declarative YAML and provides commands to manage
that state.

{{< install >}}

{{< button href="/docs/" >}}Read the docs{{< /button >}}
{{< button href="https://github.com/davidklassen/winch" >}}View the source{{< /button >}}
{{< /hero >}}

A plain Linux server is the cheapest place to run software: a VPS for a
few euros a month, a bare-metal machine in a data center, or a small
computer at home. The same compute costs several times more on AWS,
Google Cloud, or Azure. Serverless platforms such as Cloudflare Workers
charge for each request and lock you into their runtime. People paid
that price because a server needed someone to run it. Now you can ask
a coding agent to set up a secure server, and it does. One person with
side projects, or a small team, can run their own machines without an
ops person or a cloud.

But an agent's work ends up in a chat history. When the server dies,
nobody knows how to set it up again. With winch, the setup lives in
files that you review and the agent changes. You can put them under
version control, and the same files rebuild the server on a new
machine.

An agent with a shell can also break a server with one command. Most
such mistakes come from missing information: an unclear error message,
or a side effect that nobody noticed. winch makes sure that you, or your
agent, know what is going on. It checks the whole project before it
connects to a server, and each error names the file, the line, and the
cause. The plan shows every change before it happens, and notes what
else the change will cause. And a server recovers on its own when a
change to SSH or the firewall goes wrong.

One more thing that matters is speed. AI agents change the setup, look
at the result, and fix it, many times a day, and they should not spend
most of that time waiting. winch plans 3 to 50 times faster than an
Ansible check run.

{{< button href="/docs/" >}}Get started{{< /button >}}
