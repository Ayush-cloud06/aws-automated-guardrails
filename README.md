# 🛡️ AWS Automated Guardrails System

The **AWS Automated Guardrails System** is a security automation platform that makes cloud security **self-enforcing**.

This project ensures that security rules are continuously enforced through pipelines, detection systems, and automatic remediation.

If someone tries to deploy insecure infrastructure or weaken security controls, the system:

* 🚫 Blocks it
* 🔍 Detects it
* 🔧 Fixes it
* 📢 Alerts you

This is **Level 2** in the security maturity model.

---

## 🧠 Core Idea

Security should not rely on people remembering rules.
Security should be enforced by systems.

```
Developer → CI/CD → Policy Checks → AWS → Detection → Remediation → Alerts
```

A closed-loop security engine.

---

## 🚦 What This System Provides

### 🟢 Preventive Controls (Before Deployment)

CI/CD pipeline that runs:

* Terraform Plan
* Checkov
* tfsec
* OPA (Open Policy Agent)

The pipeline fails if:

* ❌ S3 buckets are public
* ❌ SSH is open to the world
* ❌ Encryption is missing
* ❌ Terraform violates internal security policies

Nothing insecure reaches AWS.

---

### 🟡 Detective Controls (After Deployment)

AWS-native detection:

* **AWS Config**

  * Detects configuration drift
  * Rules for:

    * Public S3
    * Open security groups
    * Root MFA compliance

* **GuardDuty**

  * Detects malicious or suspicious behavior

* **Security Hub**

  * Centralized security posture dashboard

---

### 🔴 Corrective Controls (Automatic Remediation)

Event-driven remediation using:

* EventBridge
* Lambda
* SNS

Examples:

| 🚨 Event                 | 🛠️ Action           |
| ------------------------ | -------------------- |
| Root access key created  | Delete key + alert   |
| S3 bucket becomes public | Block access + alert |
| Security group opens SSH | Revoke rule + alert  |

Security becomes **self-healing**.

---

## 🗂️ Repository Structure

```text
aws-automated-guardrails/
├── .github/
│   └── workflows/
│       └── guardrails.yml        # 🔥 Executed CI pipeline
├── pipeline/
│   └── github_actions.yml        # 📘 Same pipeline for documentation
├── opa/
│   └── policies/                 # 🧠 Rego policies (Cloud law)
├── terraform/
│   └── test-infra/               # 🧪 Intentionally insecure examples
└── README.md
```

> ⚠️ Note:
> Only files inside `.github/workflows/` are executed by GitHub.
> The `pipeline/` folder exists for architecture clarity and portfolio readability.

---

## 🧩 Security Model

This system uses layered enforcement:

| Layer                | Purpose                       |
| -------------------- | ----------------------------- |
| CI/CD                | Prevent bad infrastructure    |
| OPA                  | Enforce internal security law |
| AWS Config           | Detect configuration drift    |
| GuardDuty            | Detect threats                |
| EventBridge + Lambda | Automatic remediation         |
| SNS                  | Central alerting              |

Together they form:

```
Prevent → Detect → Fix → Notify
```

---

## 🔗 Relationship to Level 1

This project assumes the existence of:

> **AWS Secure Landing Zone (Level 1)**

| Level   | Purpose                             |
| ------- | ----------------------------------- |
| Level 1 | Secures the AWS account itself      |
| Level 2 | Makes security impossible to bypass |

They are designed to work together.

---

## 🧬 Philosophy

Most security systems **detect** problems.
This system **prevents and corrects** them.

Most security depends on humans.
This system **enforces security by default**.

That is what makes this a **Guardrails System**.
