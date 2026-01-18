# 🛡️ AWS Automated Guardrails System

The **AWS Automated Guardrails System** is a cloud security automation platform that makes security **self-enforcing by design**.

It ensures that security rules are not just documented or reviewed, but continuously enforced through pipelines, detection systems, and automatic remediation.

If anyone tries to deploy insecure infrastructure or weaken security controls, the system will:

* 🚫 Block it
* 🔍 Detect it
* 🔧 Fix it
* 📢 Alert you

This represents **Level 2** in a cloud security maturity model:
from *secure-by-setup* → to *secure-by-automation*.

---

## 🧠 Core Idea

Security should not depend on people remembering rules.
Security should be enforced by systems.

```
Developer → CI/CD → Policy Checks → AWS → Detection → Remediation → Alerts
```

This creates a **closed-loop security engine**.

No silent failures.
No forgotten controls.
No human dependency.

---

## 🚦 What This System Provides

### 🟢 Preventive Controls (Before Deployment)

Security starts in the pipeline.

The CI/CD pipeline runs:

* Terraform Plan
* Checkov
* tfsec
* OPA (Open Policy Agent)

The pipeline fails if:

* ❌ S3 buckets are public
* ❌ SSH is open to the world
* ❌ Encryption is missing
* ❌ Terraform violates internal security policies

Nothing insecure is allowed to reach AWS.

This is **shift-left security** done properly.

---

### 🟡 Detective Controls (After Deployment)

AWS-native detection ensures visibility and drift detection:

#### 🔍 AWS Config

* Detects configuration drift
* Rules for:

  * Public S3 buckets
  * Open security group ports
  * Root MFA compliance

#### 🛡️ GuardDuty

* Detects malicious and suspicious activity
* Credential compromise
* Unusual API behavior
* Reconnaissance or brute force attempts

#### 📊 Security Hub

* Centralized security posture dashboard
* Aggregates:

  * AWS Config findings
  * GuardDuty findings
  * Compliance signals

---

### 🔴 Corrective Controls (Automatic Remediation)

Security becomes **self-healing** using:

* EventBridge
* Lambda
* SNS

Event-driven remediation:

| 🚨 Event                 | 🛠️ Action           |
| ------------------------ | -------------------- |
| Root access key created  | Delete key + alert   |
| S3 bucket becomes public | Block access + alert |
| Security group opens SSH | Revoke rule + alert  |

The system does not wait for humans.
It fixes violations instantly.

---

## 🗂️ Repository Structure

```text
aws-automated-guardrails/
├── aws-config/           # 🔍 AWS Config rules & recorder
├── eventbridge/          # ⚡ Detection → Trigger mapping
├── lambda/               # 🔧 Remediation logic
├── alerts/               # 📢 SNS alerting
├── security/             # 🛡 GuardDuty + Security Hub
├── opa/                  # 🧠 Policy-as-code (Rego)
├── pipeline/             # 📘 CI pipeline (documentation copy)
├── .github/
│   └── workflows/        # 🔥 Actual running GitHub Actions
├── terraform/            # 🧪 Demo/test infrastructure
└── README.md
```

> ⚠️ Important
> Only files inside `.github/workflows/` are executed by GitHub Actions.
> The `pipeline/` directory exists for:

* Documentation clarity
* Architecture explanation
* Portfolio readability

---

## 🧩 Security Model

This system uses **layered enforcement**:

| Layer                | Purpose                       |
| -------------------- | ----------------------------- |
| CI/CD                | Prevent bad infrastructure    |
| OPA                  | Enforce internal security law |
| AWS Config           | Detect configuration drift    |
| GuardDuty            | Detect threats and compromise |
| EventBridge + Lambda | Automatic remediation         |
| SNS                  | Centralized alerting          |
| Security Hub         | Unified security posture      |

Together:

```
Prevent → Detect → Fix → Notify
```

This is a real-world security control loop.

---

## 🔗 Relationship to Level 1

This project assumes the existence of:

> **AWS Secure Landing Zone (Level 1)**

| Level   | Purpose                             |
| ------- | ----------------------------------- |
| Level 1 | Secures the AWS account foundation  |
| Level 2 | Makes security impossible to bypass |

Level 1 builds safety.
Level 2 enforces safety.

---

## 🧬 Philosophy

Most systems only **detect** problems.
This system **prevents, detects, and corrects** them.

Most security depends on humans.
This system **enforces security automatically**.

That is what makes this a **Guardrails System**.

Not advice.
Not guidelines.
**Law.**
