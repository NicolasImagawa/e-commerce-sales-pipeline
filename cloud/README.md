![stepfunctions_graph](https://github.com/user-attachments/assets/d1fafadd-c463-4614-8fba-cc8042f23f2e)> [!IMPORTANT]
> The cloud pipeline is still under development.

# Overview
This open-source data pipeline shows sales results from Shopee, a major e-commerce platform in Brazil. The results are accomplished through an ELT pipeline using AWS tools that stores data in a AWS Redshift star-schema data warehouse.

The orchestration is still under development

## Contents
- [Tools and technologies used for the pipeline development](#tools-and-technologies-used-for-the-pipeline-development)
- [Charts](#charts)
- [Requirements](#requirements)
- [Creating IAM roles](#creating-iam-roles)
- [Running the pipeline](#running-the-pipeline)
  - [Configuring and running Terraform](#configuring-and-running-terraform)
  - [Loading local files to S3](#loading-local-files-to-s3)
  - [Connect and transfer files to EC2](#connect-and-transfer-files-to-ec2)
  - [Running the rest of the pipeline](#running-the-rest-of-the-pipeline)
  - [Under development](#under-development)
- [Contact](#contact)
  
## Tools and technologies used for the pipeline development
The following picture shows how the pipeline works end-to-end.
  
  <br>

<img width="1276" height="455" alt="image" src="https://github.com/user-attachments/assets/e11c7491-a84d-4dc0-a607-4009c999daa2" />

  <br>
  
- Data Warehouse: Redshift serverless;
- Infrastructure: Terraform creates the EC2 instance, the S3 buckets, Redshift namespace and workgroups, while also creating the connection between EC2 and Redshift.
- Extraction: Python to extract the data and transform into .csv file;
- Cleaning: Pandas;
- Loading:
  - Python: when loading the files to AWS S3;
  - dlt, pandas and Python: to load Shopee .csv data after ensuring data types and adding load timestamps;
- Transformation: dbt inside Redshift;
- Orchestration: Done with AWS Step Functions.

## Details about the orchestration
Below, one can see the workflow for the AWS Step Function usage in this pipeline.

![Uploading stepfunctions_graph.sv<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "https://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg xmlns="http://www.w3.org/2000/svg" class="sc-dQEtJz laFPgZ graph" data-testid="graph" role="img" aria-labelledby="polymath-graph-title" width="1466" height="1674">
<title id="polymath-graph-title">Workflow Studio State Machine Graph</title>
<g transform="translate(12,12)" class="new-look-graph">
<g class="nodes">
<g class="node-container" transform="translate(738.25,22)">
<g>
<circle class="sc-kbousE cwOTqA shape" r="22"/>
<text class="sc-gfoqjT kohnMw label">
<tspan xml:space="preserve" text-anchor="middle" alignment-baseline="central">Start</tspan>
</text>
</g>
</g>
<g class="node-container" transform="translate(738.25,103.5)">
<g class="sc-cmaqmh cqiPZP node state Task" data-testid="graph-CreateExternalTables" data-state-id="CreateExternalTables" data-state-type="Task">
<g class="new-look-state-node ">
<rect x="-133.5" y="-24.5" width="267" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-133.5,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-117.5,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-service-systems-manager" aria-hidden="true">
<title>Systems Manager</title>
</use>
</g>
<g class="text-lines" transform="translate(-61.5,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Systems Manager: SendCommand</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">CreateExternalTables</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(738.25,187.5)">
<g class="sc-cmaqmh cqiPZP node state Wait" data-testid="graph-WaitForCreateExternalTables" data-state-id="WaitForCreateExternalTables" data-state-type="Wait">
<g class="new-look-state-node ">
<rect x="-132.5" y="-24.5" width="265" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-132.5,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-116.5,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-flow-wait"/>
</g>
<g class="text-lines" transform="translate(-60.5,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Wait state</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">WaitForCreateExternalTables</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(641.75,271.5)">
<g class="sc-cmaqmh cqiPZP node state Task" data-testid="graph-CheckCreateExternalTables" data-state-id="CheckCreateExternalTables" data-state-type="Task">
<g class="new-look-state-node ">
<rect x="-158" y="-24.5" width="316" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-158,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-142,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-service-systems-manager" aria-hidden="true">
<title>Systems Manager</title>
</use>
</g>
<g class="text-lines" transform="translate(-86,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Systems Manager: GetCommandInvocation</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">CheckCreateExternalTables</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(738.25,355.5)">
<g class="sc-cmaqmh cqiPZP node state Choice" data-testid="graph-EvaluateCreateExternalTables" data-state-id="EvaluateCreateExternalTables" data-state-type="Choice">
<g class="new-look-state-node ">
<rect x="-135" y="-24.5" width="270" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-135,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-119,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-flow-choice"/>
</g>
<g class="text-lines" transform="translate(-63,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Choice state</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">EvaluateCreateExternalTables</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(597,456)">
<g class="sc-cmaqmh cqiPZP node state Task" data-testid="graph-LoadToStgBucket" data-state-id="LoadToStgBucket" data-state-type="Task">
<g class="new-look-state-node ">
<rect x="-133.5" y="-24.5" width="267" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-133.5,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-117.5,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-service-systems-manager" aria-hidden="true">
<title>Systems Manager</title>
</use>
</g>
<g class="text-lines" transform="translate(-61.5,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Systems Manager: SendCommand</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">LoadToStgBucket</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(1318.5,1546.5)">
<g class="sc-cmaqmh cqiPZP node state Fail" data-testid="graph-HandleCreateTableFailure" data-state-id="HandleCreateTableFailure" data-state-type="Fail">
<g class="new-look-state-node ">
<rect x="-122.5" y="-24.5" width="245" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-122.5,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-106.5,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-flow-fail"/>
</g>
<g class="text-lines" transform="translate(-50.5,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Fail state</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">HandleCreateTableFailure</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(597,540)">
<g class="sc-cmaqmh cqiPZP node state Wait" data-testid="graph-WaitForLoadToStgBucket" data-state-id="WaitForLoadToStgBucket" data-state-type="Wait">
<g class="new-look-state-node ">
<rect x="-121" y="-24.5" width="242" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-121,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-105,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-flow-wait"/>
</g>
<g class="text-lines" transform="translate(-49,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Wait state</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">WaitForLoadToStgBucket</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(500.5,624)">
<g class="sc-cmaqmh cqiPZP node state Task" data-testid="graph-CheckLoadToStgBucketStatus" data-state-id="CheckLoadToStgBucketStatus" data-state-type="Task">
<g class="new-look-state-node ">
<rect x="-158" y="-24.5" width="316" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-158,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-142,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-service-systems-manager" aria-hidden="true">
<title>Systems Manager</title>
</use>
</g>
<g class="text-lines" transform="translate(-86,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Systems Manager: GetCommandInvocation</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">CheckLoadToStgBucketStatus</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(597,708)">
<g class="sc-cmaqmh cqiPZP node state Choice" data-testid="graph-EvaluateLoadToStgBucket" data-state-id="EvaluateLoadToStgBucket" data-state-type="Choice">
<g class="new-look-state-node ">
<rect x="-123.5" y="-24.5" width="247" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-123.5,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-107.5,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-flow-choice"/>
</g>
<g class="text-lines" transform="translate(-51.5,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Choice state</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">EvaluateLoadToStgBucket</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(457,808.5)">
<g class="sc-cmaqmh cqiPZP node state Task" data-testid="graph-InstallDbtDeps" data-state-id="InstallDbtDeps" data-state-type="Task">
<g class="new-look-state-node ">
<rect x="-133.5" y="-24.5" width="267" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-133.5,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-117.5,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-service-systems-manager" aria-hidden="true">
<title>Systems Manager</title>
</use>
</g>
<g class="text-lines" transform="translate(-61.5,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Systems Manager: SendCommand</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">InstallDbtDeps</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(1036,1546.5)">
<g class="sc-cmaqmh cqiPZP node state Fail" data-testid="graph-HandleLoadFailure" data-state-id="HandleLoadFailure" data-state-type="Fail">
<g class="new-look-state-node ">
<rect x="-120" y="-24.5" width="240" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-120,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-104,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-flow-fail"/>
</g>
<g class="text-lines" transform="translate(-48,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Fail state</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">HandleLoadFailure</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(457,892.5)">
<g class="sc-cmaqmh cqiPZP node state Wait" data-testid="graph-WaitForDbtDeps" data-state-id="WaitForDbtDeps" data-state-type="Wait">
<g class="new-look-state-node ">
<rect x="-120" y="-24.5" width="240" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-120,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-104,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-flow-wait"/>
</g>
<g class="text-lines" transform="translate(-48,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Wait state</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">WaitForDbtDeps</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(360.5,993)">
<g class="sc-cmaqmh cqiPZP node state Task" data-testid="graph-CheckDbtDepsStatus" data-state-id="CheckDbtDepsStatus" data-state-type="Task">
<g class="new-look-state-node ">
<rect x="-158" y="-24.5" width="316" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-158,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-142,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-service-systems-manager" aria-hidden="true">
<title>Systems Manager</title>
</use>
</g>
<g class="text-lines" transform="translate(-86,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Systems Manager: GetCommandInvocation</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">CheckDbtDepsStatus</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(457,1077)">
<g class="sc-cmaqmh cqiPZP node state Choice" data-testid="graph-EvaluateDbtDeps" data-state-id="EvaluateDbtDeps" data-state-type="Choice">
<g class="new-look-state-node ">
<rect x="-120" y="-24.5" width="240" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-120,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-104,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-flow-choice"/>
</g>
<g class="text-lines" transform="translate(-48,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Choice state</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">EvaluateDbtDeps</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(317,1177.5)">
<g class="sc-cmaqmh cqiPZP node state Task" data-testid="graph-RunDbt" data-state-id="RunDbt" data-state-type="Task">
<g class="new-look-state-node ">
<rect x="-133.5" y="-24.5" width="267" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-133.5,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-117.5,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-service-systems-manager" aria-hidden="true">
<title>Systems Manager</title>
</use>
</g>
<g class="text-lines" transform="translate(-61.5,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Systems Manager: SendCommand</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">RunDbt</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(756,1546.5)">
<g class="sc-cmaqmh cqiPZP node state Fail" data-testid="graph-HandleDbtDepsFailure" data-state-id="HandleDbtDepsFailure" data-state-type="Fail">
<g class="new-look-state-node ">
<rect x="-120" y="-24.5" width="240" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-120,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-104,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-flow-fail"/>
</g>
<g class="text-lines" transform="translate(-48,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Fail state</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">HandleDbtDepsFailure</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(317,1261.5)">
<g class="sc-cmaqmh cqiPZP node state Wait" data-testid="graph-WaitForDbtRun" data-state-id="WaitForDbtRun" data-state-type="Wait">
<g class="new-look-state-node ">
<rect x="-120" y="-24.5" width="240" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-120,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-104,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-flow-wait"/>
</g>
<g class="text-lines" transform="translate(-48,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Wait state</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">WaitForDbtRun</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(220.5,1362)">
<g class="sc-cmaqmh cqiPZP node state Task" data-testid="graph-CheckDbtRunStatus" data-state-id="CheckDbtRunStatus" data-state-type="Task">
<g class="new-look-state-node ">
<rect x="-158" y="-24.5" width="316" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-158,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-142,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-service-systems-manager" aria-hidden="true">
<title>Systems Manager</title>
</use>
</g>
<g class="text-lines" transform="translate(-86,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Systems Manager: GetCommandInvocation</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">CheckDbtRunStatus</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(317,1446)">
<g class="sc-cmaqmh cqiPZP node state Choice" data-testid="graph-EvaluateDbtRun" data-state-id="EvaluateDbtRun" data-state-type="Choice">
<g class="new-look-state-node ">
<rect x="-120" y="-24.5" width="240" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-120,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-104,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-flow-choice"/>
</g>
<g class="text-lines" transform="translate(-48,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Choice state</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">EvaluateDbtRun</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(158,1546.5)">
<g class="sc-cmaqmh cqiPZP node state Task" data-testid="graph-EndPipeline" data-state-id="EndPipeline" data-state-type="Task">
<g class="new-look-state-node ">
<rect x="-158" y="-24.5" width="316" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-158,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-142,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-service-systems-manager" aria-hidden="true">
<title>Systems Manager</title>
</use>
</g>
<g class="text-lines" transform="translate(-86,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Systems Manager: GetCommandInvocation</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">EndPipeline</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(476,1546.5)">
<g class="sc-cmaqmh cqiPZP node state Fail" data-testid="graph-HandleDbtRunFailure" data-state-id="HandleDbtRunFailure" data-state-type="Fail">
<g class="new-look-state-node ">
<rect x="-120" y="-24.5" width="240" height="49" rx="3" ry="3"/>
<g class="handle" transform="translate(-120,-24.5)">
<path d="M5,16 L5,34 M8,16 L8,34"/>
</g>
<g class="icon" transform="translate(-104,-24)">
<rect fill="var(--color-background-container-header-etndi4, #fafafa)" x="0.0361026108" y="0.0181291967" width="48" height="48"/>
<line x1="47.5" y1="0.49122807" x2="47.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<line x1="0.5" y1="0.49122807" x2="0.5" y2="47.5" stroke="var(--color-board-placeholder-active-qurjro, #d5dbdb)" stroke-linecap="square"/>
<use href="#icon-flow-fail"/>
</g>
<g class="text-lines" transform="translate(-48,-24.5)">
<text transform="translate(0,17)" class="line1">
<tspan xml:space="preserve" text-anchor="start">Fail state</tspan>
</text>
<text transform="translate(0,35.5)" class="line2 label">
<tspan xml:space="preserve" text-anchor="start">HandleDbtRunFailure</tspan>
</text>
</g>
</g>
</g>
</g>
<g class="node-container" transform="translate(756,1628)">
<g>
<circle class="sc-kbousE cwOTqA shape" r="22"/>
<text class="sc-gfoqjT kohnMw label">
<tspan xml:space="preserve" text-anchor="middle" alignment-baseline="central">End</tspan>
</text>
</g>
</g>
</g>
<g class="edges">
<g class="sc-kAkpmW eGruRC edge">
<path id="state-CreateExternalTables:state-WaitForCreateExternalTables:normal" d="M738.25,128L738.25,130.91666666666666C738.25,133.83333333333334,738.25,139.66666666666666,738.25,145.5C738.25,151.33333333333334,738.25,157.16666666666666,738.25,160.08333333333334L738.25,163" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="start:state-CreateExternalTables" d="M738.25,44L738.25,46.916666666666664C738.25,49.833333333333336,738.25,55.666666666666664,738.25,61.5C738.25,67.33333333333333,738.25,73.16666666666667,738.25,76.08333333333333L738.25,79" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-WaitForCreateExternalTables:state-CheckCreateExternalTables:normal" d="M681.9583333333334,212L675.2569444444445,214.91666666666666C668.5555555555555,217.83333333333334,655.1527777777778,223.66666666666666,648.4513888888889,229.5C641.75,235.33333333333334,641.75,241.16666666666666,641.75,244.08333333333334L641.75,247" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-CheckCreateExternalTables:state-EvaluateCreateExternalTables:normal" d="M641.75,296L641.75,298.9166666666667C641.75,301.8333333333333,641.75,307.6666666666667,648.4513888888889,313.5C655.1527777777778,319.3333333333333,668.5555555555555,325.1666666666667,675.2569444444445,328.0833333333333L681.9583333333334,331" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-EvaluateCreateExternalTables:state-LoadToStgBucket:choiceRule:0" d="M669.3818407960199,380L657.3182006633499,384.2916666666667C645.2545605306799,388.5833333333333,621.1272802653399,397.1666666666667,609.06364013267,405.75C597,414.3333333333333,597,422.9166666666667,597,427.2083333333333L597,431.5" marker-end="url(#arrowhead)" fill="none"/>
<g data-testid="graph-EvaluateCreateExternalTables-0" class="edge-label" transform="translate(609.06364013267,405.75)">
<rect x="-101" y="-8.25" width="202" height="16.5" class="sc-gFVvzn fzbdhh"/>
<text class="sc-brPLxw hgiJwm label">
<tspan xml:space="preserve" text-anchor="middle" alignment-baseline="central">$.CheckCreateExternalTables.Status == "…</tspan>
<title>$.CheckCreateExternalTables.Status == "Success"</title>
</text>
</g>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-EvaluateCreateExternalTables:state-HandleCreateTableFailure:choiceRule:1" d="M873.25,367.1910814304179L947.4583333333334,373.61756785868164C1021.6666666666666,380.04405428694525,1170.0833333333333,392.8970271434726,1244.2916666666667,407.6985135717363C1318.5,422.5,1318.5,439.25,1318.5,454.625C1318.5,470,1318.5,484,1318.5,498C1318.5,512,1318.5,526,1318.5,540C1318.5,554,1318.5,568,1318.5,582C1318.5,596,1318.5,610,1318.5,624C1318.5,638,1318.5,652,1318.5,666C1318.5,680,1318.5,694,1318.5,709.375C1318.5,724.75,1318.5,741.5,1318.5,758.25C1318.5,775,1318.5,791.75,1318.5,807.125C1318.5,822.5,1318.5,836.5,1318.5,850.5C1318.5,864.5,1318.5,878.5,1318.5,893.875C1318.5,909.25,1318.5,926,1318.5,942.75C1318.5,959.5,1318.5,976.25,1318.5,991.625C1318.5,1007,1318.5,1021,1318.5,1035C1318.5,1049,1318.5,1063,1318.5,1078.375C1318.5,1093.75,1318.5,1110.5,1318.5,1127.25C1318.5,1144,1318.5,1160.75,1318.5,1176.125C1318.5,1191.5,1318.5,1205.5,1318.5,1219.5C1318.5,1233.5,1318.5,1247.5,1318.5,1262.875C1318.5,1278.25,1318.5,1295,1318.5,1311.75C1318.5,1328.5,1318.5,1345.25,1318.5,1360.625C1318.5,1376,1318.5,1390,1318.5,1404C1318.5,1418,1318.5,1432,1318.5,1447.375C1318.5,1462.75,1318.5,1479.5,1318.5,1492.1666666666667C1318.5,1504.8333333333333,1318.5,1513.4166666666667,1318.5,1517.7083333333333L1318.5,1522" marker-end="url(#arrowhead)" fill="none"/>
<g data-testid="graph-EvaluateCreateExternalTables-1" class="edge-label" transform="translate(1244.2916666666667,407.6985135717363)">
<rect x="-101" y="-8.25" width="202" height="16.5" class="sc-gFVvzn fzbdhh"/>
<text class="sc-brPLxw hgiJwm label">
<tspan xml:space="preserve" text-anchor="middle" alignment-baseline="central">$.CheckCreateExternalTables.Status == "…</tspan>
<title>$.CheckCreateExternalTables.Status == "Failed"</title>
</text>
</g>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-EvaluateCreateExternalTables:state-WaitForCreateExternalTables:choiceDefault" d="M794.5416666666666,331L801.2430555555555,328.0833333333333C807.9444444444443,325.1666666666667,821.3472222222222,319.3333333333333,828.0486111111112,309.4166666666667C834.75,299.5,834.75,285.5,834.75,271.5C834.75,257.5,834.75,243.5,828.0486111111112,233.58333333333334C821.3472222222222,223.66666666666666,807.9444444444443,217.83333333333334,801.2430555555555,214.91666666666666L794.5416666666666,212" marker-end="url(#arrowhead)" fill="none"/>
<g data-testid="graph-EvaluateCreateExternalTables-Default" class="edge-label" transform="translate(828.0486111111112,309.4166666666667)">
<rect x="-22" y="-8.25" width="44" height="16.5" class="sc-gFVvzn fzbdhh"/>
<text class="sc-brPLxw hgiJwm label">
<tspan xml:space="preserve" text-anchor="middle" alignment-baseline="central">Default</tspan>
<title>Default</title>
</text>
</g>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-LoadToStgBucket:state-WaitForLoadToStgBucket:normal" d="M597,480.5L597,483.4166666666667C597,486.3333333333333,597,492.1666666666667,597,498C597,503.8333333333333,597,509.6666666666667,597,512.5833333333334L597,515.5" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-WaitForLoadToStgBucket:state-CheckLoadToStgBucketStatus:normal" d="M540.7083333333334,564.5L534.0069444444445,567.4166666666666C527.3055555555555,570.3333333333334,513.9027777777778,576.1666666666666,507.2013888888889,582C500.5,587.8333333333334,500.5,593.6666666666666,500.5,596.5833333333334L500.5,599.5" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-CheckLoadToStgBucketStatus:state-EvaluateLoadToStgBucket:normal" d="M500.5,648.5L500.5,651.4166666666666C500.5,654.3333333333334,500.5,660.1666666666666,507.2013888888889,666C513.9027777777778,671.8333333333334,527.3055555555555,677.6666666666666,534.0069444444445,680.5833333333334L540.7083333333334,683.5" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-EvaluateLoadToStgBucket:state-InstallDbtDeps:choiceRule:0" d="M528.7412935323383,732.5L516.7844112769486,736.7916666666666C504.82752902155886,741.0833333333334,480.9137645107794,749.6666666666666,468.9568822553897,758.25C457,766.8333333333334,457,775.4166666666666,457,779.7083333333334L457,784" marker-end="url(#arrowhead)" fill="none"/>
<g data-testid="graph-EvaluateLoadToStgBucket-0" class="edge-label" transform="translate(468.9568822553897,758.25)">
<rect x="-101.5" y="-8.25" width="203" height="16.5" class="sc-gFVvzn fzbdhh"/>
<text class="sc-brPLxw hgiJwm label">
<tspan xml:space="preserve" text-anchor="middle" alignment-baseline="central">$.CheckLoadToStgBucketStatus.Status =…</tspan>
<title>$.CheckLoadToStgBucketStatus.Status == "Success"</title>
</text>
</g>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-EvaluateLoadToStgBucket:state-HandleLoadFailure:choiceRule:1" d="M720.5,722.1363895216401L773.0833333333334,728.1553246013667C825.6666666666666,734.1742596810933,930.8333333333334,746.2121298405467,983.4166666666666,760.6060649202733C1036,775,1036,791.75,1036,807.125C1036,822.5,1036,836.5,1036,850.5C1036,864.5,1036,878.5,1036,893.875C1036,909.25,1036,926,1036,942.75C1036,959.5,1036,976.25,1036,991.625C1036,1007,1036,1021,1036,1035C1036,1049,1036,1063,1036,1078.375C1036,1093.75,1036,1110.5,1036,1127.25C1036,1144,1036,1160.75,1036,1176.125C1036,1191.5,1036,1205.5,1036,1219.5C1036,1233.5,1036,1247.5,1036,1262.875C1036,1278.25,1036,1295,1036,1311.75C1036,1328.5,1036,1345.25,1036,1360.625C1036,1376,1036,1390,1036,1404C1036,1418,1036,1432,1036,1447.375C1036,1462.75,1036,1479.5,1036,1492.1666666666667C1036,1504.8333333333333,1036,1513.4166666666667,1036,1517.7083333333333L1036,1522" marker-end="url(#arrowhead)" fill="none"/>
<g data-testid="graph-EvaluateLoadToStgBucket-1" class="edge-label" transform="translate(983.4166666666666,760.6060649202733)">
<rect x="-101.5" y="-8.25" width="203" height="16.5" class="sc-gFVvzn fzbdhh"/>
<text class="sc-brPLxw hgiJwm label">
<tspan xml:space="preserve" text-anchor="middle" alignment-baseline="central">$.CheckLoadToStgBucketStatus.Status =…</tspan>
<title>$.CheckLoadToStgBucketStatus.Status == "Failed"</title>
</text>
</g>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-EvaluateLoadToStgBucket:state-WaitForLoadToStgBucket:choiceDefault" d="M720.5,698.4519098021169L790.4583333333334,693.0432581684308C860.4166666666666,687.6346065347446,1000.3333333333334,676.8173032673723,1070.2916666666667,664.4086516336862C1140.25,652,1140.25,638,1140.25,624C1140.25,610,1140.25,596,1069.875,583.5591348366314C999.5,571.1182696732627,858.75,560.2365393465255,788.375,554.7956741831568L718,549.3548090197883" marker-end="url(#arrowhead)" fill="none"/>
<g data-testid="graph-EvaluateLoadToStgBucket-Default" class="edge-label" transform="translate(1070.2916666666667,664.4086516336862)">
<rect x="-22" y="-8.25" width="44" height="16.5" class="sc-gFVvzn fzbdhh"/>
<text class="sc-brPLxw hgiJwm label">
<tspan xml:space="preserve" text-anchor="middle" alignment-baseline="central">Default</tspan>
<title>Default</title>
</text>
</g>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-InstallDbtDeps:state-WaitForDbtDeps:normal" d="M457,833L457,835.9166666666666C457,838.8333333333334,457,844.6666666666666,457,850.5C457,856.3333333333334,457,862.1666666666666,457,865.0833333333334L457,868" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-WaitForDbtDeps:state-CheckDbtDepsStatus:normal" d="M409.9502487562189,917L401.7085406301824,921.2916666666666C393.46683250414594,925.5833333333334,376.983416252073,934.1666666666666,368.7417081260365,942.75C360.5,951.3333333333334,360.5,959.9166666666666,360.5,964.2083333333334L360.5,968.5" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-CheckDbtDepsStatus:state-EvaluateDbtDeps:normal" d="M360.5,1017.5L360.5,1020.4166666666666C360.5,1023.3333333333334,360.5,1029.1666666666667,367.2013888888889,1035C373.90277777777777,1040.8333333333333,387.3055555555555,1046.6666666666667,394.0069444444444,1049.5833333333333L400.7083333333333,1052.5" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-EvaluateDbtDeps:state-RunDbt:choiceRule:0" d="M388.7412935323383,1101.5L376.78441127694856,1105.7916666666667C364.82752902155886,1110.0833333333333,340.91376451077946,1118.6666666666667,328.9568822553897,1127.25C317,1135.8333333333333,317,1144.4166666666667,317,1148.7083333333333L317,1153" marker-end="url(#arrowhead)" fill="none"/>
<g data-testid="graph-EvaluateDbtDeps-0" class="edge-label" transform="translate(328.9568822553897,1127.25)">
<rect x="-100.5" y="-8.25" width="201" height="16.5" class="sc-gFVvzn fzbdhh"/>
<text class="sc-brPLxw hgiJwm label">
<tspan xml:space="preserve" text-anchor="middle" alignment-baseline="central">$.CheckDbtDepsStatus.Status == "Succe…</tspan>
<title>$.CheckDbtDepsStatus.Status == "Success"</title>
</text>
</g>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-EvaluateDbtDeps:state-HandleDbtDepsFailure:choiceRule:1" d="M577,1097.1672240802675L606.8333333333334,1102.1810200668895C636.6666666666666,1107.1948160535117,696.3333333333334,1117.2224080267558,726.1666666666666,1130.6112040133778C756,1144,756,1160.75,756,1176.125C756,1191.5,756,1205.5,756,1219.5C756,1233.5,756,1247.5,756,1262.875C756,1278.25,756,1295,756,1311.75C756,1328.5,756,1345.25,756,1360.625C756,1376,756,1390,756,1404C756,1418,756,1432,756,1447.375C756,1462.75,756,1479.5,756,1492.1666666666667C756,1504.8333333333333,756,1513.4166666666667,756,1517.7083333333333L756,1522" marker-end="url(#arrowhead)" fill="none"/>
<g data-testid="graph-EvaluateDbtDeps-1" class="edge-label" transform="translate(726.1666666666666,1130.6112040133778)">
<rect x="-101" y="-8.25" width="202" height="16.5" class="sc-gFVvzn fzbdhh"/>
<text class="sc-brPLxw hgiJwm label">
<tspan xml:space="preserve" text-anchor="middle" alignment-baseline="central">$.CheckDbtDepsStatus.Status == "Failed…</tspan>
<title>$.CheckDbtDepsStatus.Status == "Failed"</title>
</text>
</g>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-EvaluateDbtDeps:state-WaitForDbtDeps:choiceDefault" d="M577,1064.4626865671642L624,1059.55223880597C671,1054.641791044776,765,1044.8208955223881,812,1032.910447761194C859,1021,859,1007,859,991.625C859,976.25,859,959.5,812,945.25C765,931,671,919.25,624,913.375L577,907.5" marker-end="url(#arrowhead)" fill="none"/>
<g data-testid="graph-EvaluateDbtDeps-Default" class="edge-label" transform="translate(812,1032.910447761194)">
<rect x="-22" y="-8.25" width="44" height="16.5" class="sc-gFVvzn fzbdhh"/>
<text class="sc-brPLxw hgiJwm label">
<tspan xml:space="preserve" text-anchor="middle" alignment-baseline="central">Default</tspan>
<title>Default</title>
</text>
</g>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-RunDbt:state-WaitForDbtRun:normal" d="M317,1202L317,1204.9166666666667C317,1207.8333333333333,317,1213.6666666666667,317,1219.5C317,1225.3333333333333,317,1231.1666666666667,317,1234.0833333333333L317,1237" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-WaitForDbtRun:state-CheckDbtRunStatus:normal" d="M269.9502487562189,1286L261.7085406301824,1290.2916666666667C253.46683250414594,1294.5833333333333,236.98341625207297,1303.1666666666667,228.7417081260365,1311.75C220.5,1320.3333333333333,220.5,1328.9166666666667,220.5,1333.2083333333333L220.5,1337.5" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-CheckDbtRunStatus:state-EvaluateDbtRun:normal" d="M220.5,1386.5L220.5,1389.4166666666667C220.5,1392.3333333333333,220.5,1398.1666666666667,227.20138888888889,1404C233.90277777777774,1409.8333333333333,247.30555555555554,1415.6666666666667,254.00694444444443,1418.5833333333333L260.7083333333333,1421.5" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-EvaluateDbtRun:state-EndPipeline:choiceRule:0" d="M239.47761194029852,1470.5L225.8980099502488,1474.7916666666667C212.318407960199,1479.0833333333333,185.1592039800995,1487.6666666666667,171.57960199004978,1496.25C158,1504.8333333333333,158,1513.4166666666667,158,1517.7083333333333L158,1522" marker-end="url(#arrowhead)" fill="none"/>
<g data-testid="graph-EvaluateDbtRun-0" class="edge-label" transform="translate(171.57960199004978,1496.25)">
<rect x="-102" y="-8.25" width="204" height="16.5" class="sc-gFVvzn fzbdhh"/>
<text class="sc-brPLxw hgiJwm label">
<tspan xml:space="preserve" text-anchor="middle" alignment-baseline="central">$.CheckDbtRunStatus.Status == "Success…</tspan>
<title>$.CheckDbtRunStatus.Status == "Success"</title>
</text>
</g>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-EvaluateDbtRun:state-HandleDbtRunFailure:choiceRule:1" d="M394.5223880597015,1470.5L408.10199004975124,1474.7916666666667C421.681592039801,1479.0833333333333,448.84079601990044,1487.6666666666667,462.42039800995025,1496.25C476,1504.8333333333333,476,1513.4166666666667,476,1517.7083333333333L476,1522" marker-end="url(#arrowhead)" fill="none"/>
<g data-testid="graph-EvaluateDbtRun-1" class="edge-label" transform="translate(462.42039800995025,1496.25)">
<rect x="-95.5" y="-8.25" width="191" height="16.5" class="sc-gFVvzn fzbdhh"/>
<text class="sc-brPLxw hgiJwm label">
<tspan xml:space="preserve" text-anchor="middle" alignment-baseline="central">$.CheckDbtRunStatus.Status == "Failed"</tspan>
<title>$.CheckDbtRunStatus.Status == "Failed"</title>
</text>
</g>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-EvaluateDbtRun:state-WaitForDbtRun:choiceDefault" d="M437,1426.7633587786258L460.6666666666667,1422.9694656488548C484.3333333333333,1419.175572519084,531.6666666666666,1411.5877862595419,555.3333333333334,1400.793893129771C579,1390,579,1376,579,1360.625C579,1345.25,579,1328.5,555.3333333333334,1315.5858778625955C531.6666666666666,1302.6717557251907,484.3333333333333,1293.5935114503816,460.6666666666667,1289.054389312977L437,1284.5152671755725" marker-end="url(#arrowhead)" fill="none"/>
<g data-testid="graph-EvaluateDbtRun-Default" class="edge-label" transform="translate(555.3333333333334,1400.793893129771)">
<rect x="-22" y="-8.25" width="44" height="16.5" class="sc-gFVvzn fzbdhh"/>
<text class="sc-brPLxw hgiJwm label">
<tspan xml:space="preserve" text-anchor="middle" alignment-baseline="central">Default</tspan>
<title>Default</title>
</text>
</g>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-EndPipeline:end:normal" d="M158,1571L158,1573.9166666666667C158,1576.8333333333333,158,1582.6666666666667,254.00797287491073,1591.9249970934654C350.01594574982147,1601.1833275202641,542.031891499643,1613.866655040528,638.0398643745538,1620.2083188006602L734.0478372494646,1626.5499825607924" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-HandleCreateTableFailure:end:normal" d="M1318.5,1571L1318.5,1573.9166666666667C1318.5,1576.8333333333333,1318.5,1582.6666666666667,1228.4076595039298,1591.9098176881682C1138.31531900786,1601.1529687096702,958.1306380157197,1613.8059374193406,868.0382975196495,1620.1324217741756L777.9459570235796,1626.4589061290108" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-HandleLoadFailure:end:normal" d="M1036,1571L1036,1573.9166666666667C1036,1576.8333333333333,1036,1582.6666666666667,992.9640502617352,1591.6544762428384C949.9281005234702,1600.6422858190106,863.8562010469404,1612.784571638021,820.8202513086757,1618.855714547526L777.7843015704107,1624.9268574570312" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-HandleDbtDepsFailure:end:normal" d="M756,1571L756,1573.9166666666667C756,1576.8333333333333,756,1582.6666666666667,756,1588.5C756,1594.3333333333333,756,1600.1666666666667,756,1603.0833333333333L756,1606" marker-end="url(#arrowhead)" fill="none"/>
</g>
<g class="sc-kAkpmW eGruRC edge">
<path id="state-HandleDbtRunFailure:end:normal" d="M476,1571L476,1573.9166666666667C476,1576.8333333333333,476,1582.6666666666667,519.0359497382649,1591.6544762428384C562.0718994765298,1600.6422858190106,648.1437989530596,1612.784571638021,691.1797486913243,1618.855714547526L734.2156984295893,1624.9268574570312" marker-end="url(#arrowhead)" fill="none"/>
</g>
</g>
<defs>
<marker id="arrowhead" markerWidth="8" markerHeight="6" refX="7" refY="3" orient="auto" class="sc-eyvILC khZmcS">
<polygon points="0 0, 8 3, 0 6"/>
</marker>
<marker id="highlighted-arrowhead" markerWidth="6" markerHeight="4" refX="5" refY="2" orient="auto" class="sc-eyvILC khZmcS">
<polygon points="0 0, 6 2, 0 4"/>
</marker>
<marker id="error-arrowhead" markerWidth="6" markerHeight="4" refX="5" refY="2" orient="auto" class="sc-eyvILC khZmcS">
<polygon points="0 0, 6 2, 0 4"/>
</marker>
<marker id="large-arrowhead" markerWidth="10" markerHeight="8" refX="9" refY="4" orient="auto" class="sc-eyvILC khZmcS">
<polygon points="0 0, 10 4, 0 8"/>
</marker>
<marker id="large-highlighted-arrowhead" markerWidth="5.5" markerHeight="4" refX="4.5" refY="2" orient="auto" class="sc-eyvILC khZmcS">
<polygon points="0 0, 5.5 2, 0 4"/>
</marker>
<marker id="large-error-arrowhead" markerWidth="10" markerHeight="8" refX="9" refY="4" orient="auto" class="sc-eyvILC khZmcS">
<polygon points="0 0, 10 4, 0 8"/>
</marker>
<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-orange">
<stop stop-color="#C8511B" offset="0%"/>
<stop stop-color="#FF9900" offset="100%"/>
</linearGradient>
<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-turquoise">
<stop stop-color="#055F4E" offset="0%"/>
<stop stop-color="#56C0A7" offset="100%"/>
</linearGradient>
<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-blue">
<stop stop-color="#2E27AD" offset="0%"/>
<stop stop-color="#527FFF" offset="100%"/>
</linearGradient>
<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-pink">
<stop stop-color="#B0084D" offset="0%"/>
<stop stop-color="#FF4F8B" offset="100%"/>
</linearGradient>
<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-red">
<stop stop-color="#BD0816" offset="0%"/>
<stop stop-color="#FF5252" offset="100%"/>
</linearGradient>
<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-green">
<stop stop-color="#1B660F" offset="0%"/>
<stop stop-color="#6CAE3E" offset="100%"/>
</linearGradient>
<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-purple">
<stop stop-color="#4D27A8" offset="0%"/>
<stop stop-color="#A166FF" offset="100%"/>
</linearGradient>
<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-grey">
<stop stop-color="#DCDCDC" offset="0%"/>
<stop stop-color="#F6F5F7" offset="100%"/>
</linearGradient>
<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-light-pink">
<stop stop-color="#DD344C" offset="0%"/>
<stop stop-color="#DD344C" offset="100%"/>
</linearGradient>,<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-ag">
<stop stop-color="#BC1356" offset="0%"/>
<stop stop-color="#F34482" offset="100%"/>
</linearGradient>
<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-athena">
<stop stop-color="#5930B5" offset="0%"/>
<stop stop-color="#945DF2" offset="100%"/>
</linearGradient>
<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-emr">
<stop stop-color="#5930B5" offset="0%"/>
<stop stop-color="#945DF2" offset="100%"/>
</linearGradient>
<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-glue">
<stop stop-color="#5930B5" offset="0%"/>
<stop stop-color="#945DF2" offset="100%"/>
</linearGradient>
<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-sns">
<stop stop-color="#BC1356" offset="0%"/>
<stop stop-color="#F34482" offset="100%"/>
</linearGradient>
<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-states">
<stop stop-color="#BC1356" offset="0%"/>
<stop stop-color="#F34482" offset="100%"/>
</linearGradient>
<linearGradient x1="0%" y1="100%" x2="100%" y2="0%" id="gradient-generic">
<stop stop-color="#ccc" offset="0%"/>
<stop stop-color="#ddd" offset="100%"/>
</linearGradient>
<g stroke-width="1" fill="none" fill-rule="evenodd" id="icon-flow-wait">
<path d="M26.75,8.85825893 L26.75,10.3582589 L25,10.3582589 L25.0010332,13.2887186 C27.2395643,13.4625704 29.3159269,14.2145278 31.0809903,15.3954598 L32.3188424,13.6912711 L34.7458934,15.4546269 L33.3682881,17.3513419 C35.4674483,19.6240431 36.75,22.6622436 36.75,26 C36.75,33.0416306 31.0416306,38.75 24,38.75 C16.9583694,38.75 11.25,33.0416306 11.25,26 C11.25,22.7657627 12.4542298,19.8127884 14.4387685,17.5649977 L12.9047966,15.4546269 L15.3318476,13.6912711 L16.6858812,15.555197 C18.2387522,14.4657629 20.0456704,13.7138336 22.0001068,13.4059384 L22,10.3582589 L20.25,10.3582589 L20.25,8.85825893 L26.75,8.85825893 Z M24,14.75 C17.7867966,14.75 12.75,19.7867966 12.75,26 C12.75,32.2132034 17.7867966,37.25 24,37.25 C30.2132034,37.25 35.25,32.2132034 35.25,26 C35.25,19.7867966 30.2132034,14.75 24,14.75 Z M24.4666648,19.3452148 L24.466,26.499 L30.9387207,26.4993034 L30.9387207,27.9993034 L23.7166648,27.9993034 C23.336969,27.9993034 23.0231738,27.7171495 22.9735114,27.3510739 L22.9666648,27.2493034 L22.9666648,19.3452148 L24.4666648,19.3452148 Z" fill-rule="nonzero" fill="#0073BB"/>
</g>
<g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd" id="icon-flow-choice">
<g transform="translate(9.252020, 8.729185)" fill="#0073BB" fill-rule="nonzero">
<path d="M13.7176503,0.219669914 C13.9839168,-0.0465966484 14.4005805,-0.0708026996 14.694192,0.147051761 L14.7783104,0.219669914 L26.7991257,12.2404852 C27.0653923,12.5067518 27.0895983,12.9234154 26.8717439,13.2170269 L26.7991257,13.3011454 L19.848,20.251 L27.063,27.58 L27.0635443,24.4725437 C27.0635443,24.0583302 27.3993308,23.7225437 27.8135443,23.7225437 C28.1901021,23.7225437 28.5018441,24.0000532 28.5554124,24.3617142 L28.5635443,24.4725437 L28.5635443,29.4222912 C28.5635443,29.4735748 28.5583971,29.5236562 28.5485912,29.5720469 L28.5290567,29.6477745 L28.4912259,29.7440224 L28.4674556,29.7898473 L28.4399848,29.8348433 L28.3922808,29.8993609 L28.3266417,29.9693147 L28.2903734,30.0012261 L28.2103598,30.0588356 L28.1372883,30.0990133 L28.0408973,30.1372113 L27.9243738,30.1641593 C27.8841362,30.1698129 27.8491297,30.1722912 27.8135443,30.1722912 L22.8637969,30.1722912 C22.4495833,30.1722912 22.1137969,29.8365048 22.1137969,29.4222912 C22.1137969,29.0457334 22.3913063,28.7339914 22.7529674,28.6804231 L22.8637969,28.6722912 L26.032,28.672 L18.787,21.312 L14.7783104,25.3219606 C14.5120439,25.5882272 14.0953802,25.6124333 13.8017687,25.3945788 L13.7176503,25.3219606 L9.63,21.234 L2.386,28.671 L5.69974747,28.6722912 L5.81057697,28.6804231 C6.17223802,28.7339914 6.44974747,29.0457334 6.44974747,29.4222912 C6.44974747,29.801987 6.16759359,30.1157822 5.80151803,30.1654446 L5.69974747,30.1722912 L0.75,30.1722912 L0.645175107,30.1650238 L0.571316134,30.150876 L0.491748953,30.1266437 L0.399838514,30.0857012 L0.323957521,30.0396165 L0.243169757,29.975129 L0.170912131,29.8989347 L0.109961584,29.8134582 L0.0656949991,29.7297074 L0.0297396696,29.6320944 L0.0076057584,29.5294944 L6.67910172e-13,29.4222912 L6.67910172e-13,24.4725437 L0.00813192572,24.3617142 C0.0617002376,24.0000532 0.373442216,23.7225437 0.75,23.7225437 C1.12969577,23.7225437 1.44349096,24.0046976 1.49315338,24.3707732 L1.5,24.4725437 L1.499,27.433 L8.569,20.174 L1.69683498,13.3011454 C1.43056842,13.0348788 1.40636237,12.6182151 1.62421683,12.3246036 L1.69683498,12.2404852 L13.7176503,0.219669914 Z M14.3527697,23.728356 L25.2081355,12.7708153 L14.2479803,1.81066017 L3.28782524,12.7708153 L9.616,19.099 L14.3527697,23.728356 Z" fill="false"/>
<path d="M15.2319803,14.0468153 L15.2319803,13.2668153 C16.0033137,12.8508153 16.5579803,12.4218153 16.8959803,11.9798153 C17.2339803,11.5378153 17.4029803,11.0178153 17.4029803,10.4198153 C17.4029803,9.65714861 17.151647,9.06131528 16.6489803,8.63231528 C16.1463137,8.20331528 15.448647,7.98881528 14.5559803,7.98881528 C13.6979803,7.98881528 12.874647,8.19248195 12.0859803,8.59981528 L12.0859803,8.59981528 L12.0859803,10.3288153 C12.8313137,9.98214861 13.4943137,9.80881528 14.0749803,9.80881528 C14.395647,9.80881528 14.6404803,9.87814861 14.8094803,10.0168153 C14.9784803,10.1554819 15.0629803,10.3591486 15.0629803,10.6278153 C15.0629803,10.9138153 14.9763137,11.1651486 14.8029803,11.3818153 C14.629647,11.5984819 14.343647,11.8151486 13.9449803,12.0318153 L13.9449803,12.0318153 L13.1909803,12.4348153 L13.3339803,14.0468153 L15.2319803,14.0468153 Z M14.3089803,17.4398153 C14.7249803,17.4398153 15.0608137,17.3141486 15.3164803,17.0628153 C15.572147,16.8114819 15.6999803,16.4821486 15.6999803,16.0748153 C15.6999803,15.6674819 15.572147,15.3381486 15.3164803,15.0868153 C15.0608137,14.8354819 14.7249803,14.7098153 14.3089803,14.7098153 C13.8929803,14.7098153 13.557147,14.8354819 13.3014803,15.0868153 C13.0458137,15.3381486 12.9179803,15.6674819 12.9179803,16.0748153 C12.9179803,16.4821486 13.0458137,16.8114819 13.3014803,17.0628153 C13.557147,17.3141486 13.8929803,17.4398153 14.3089803,17.4398153 Z" fill="false"/>
</g>
</g>
<g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd" id="icon-flow-fail">
<g transform="translate(11.250000, 12.250000)" fill="#D13212" fill-rule="nonzero">
<path d="M12.75,0 C5.70836944,0 0,5.70836944 0,12.75 C0,19.7916306 5.70836944,25.5 12.75,25.5 C19.7916306,25.5 25.5,19.7916306 25.5,12.75 C25.5,5.70836944 19.7916306,0 12.75,0 Z M12.75,1.5 C18.9632034,1.5 24,6.53679656 24,12.75 C24,18.9632034 18.9632034,24 12.75,24 C6.53679656,24 1.5,18.9632034 1.5,12.75 C1.5,6.53679656 6.53679656,1.5 12.75,1.5 Z"/>
<path d="M16.5831403,8.21116377 C16.8767518,7.99330931 17.2934155,8.01751536 17.559682,8.28378193 C17.8259486,8.55004849 17.8501547,8.96671217 17.6323002,9.26032366 L17.559682,9.3444421 L13.622464,13.282112 L17.559682,17.2196699 C17.8525753,17.5125631 17.8525753,17.9874369 17.559682,18.2803301 C17.2934155,18.5465966 16.8767518,18.5708027 16.5831403,18.3529482 L16.4990219,18.2803301 L12.561464,14.343112 L8.62379406,18.2803301 L8.53967563,18.3529482 C8.24606413,18.5708027 7.82940045,18.5465966 7.56313389,18.2803301 C7.29686733,18.0140635 7.27266128,17.5973998 7.49051574,17.3037883 L7.56313389,17.2196699 L11.500464,13.282112 L7.56313389,9.3444421 C7.27024067,9.05154888 7.27024067,8.57667514 7.56313389,8.28378193 C7.82940045,8.01751536 8.24606413,7.99330931 8.53967563,8.21116377 L8.62379406,8.28378193 L12.561464,12.221112 L16.4990219,8.28378193 L16.5831403,8.21116377 Z"/>
</g>
</g>
<g stroke="none" stroke-width="1" fill="none" fill-rule="evenodd" id="icon-service-systems-manager">
<polygon fill="url(#gradient-pink)" fill-rule="nonzero" points="0 0 48 0 48 48 0 48"/>
<g transform="translate(8 8) scale(0.032)">
<path d="M642.9 750L821.4 750 821.4 785.7 642.9 785.7 642.9 821.4 607.1 821.4 607.1 785.7 535.7 785.7 535.7 750 607.1 750 607.1 714.3 642.9 714.3 642.9 750ZM785.7 571.4L821.4 571.4 821.4 607.1 785.7 607.1 785.7 642.8 750 642.8 750 607.1 535.7 607.1 535.7 571.4 750 571.4 750 535.7 785.7 535.7 785.7 571.4ZM155.6 607.1L321.4 607.1 321.4 642.8 155.6 642.8C136.6 642.8 117 642.8 96.8 630.2 60.6 607.8 0 555.3 0 455.9 0 335.3 83.2 291 131.7 275.5L130.8 259.9C130.8 160.5 197.8 58.7 286.6 22 390.5-21.3 500.5 0.2 581 79.4 606.1 103.9 626.6 133.8 642.4 168.6 674.4 142.4 717.9 133.6 758.3 147.1 808.2 163.7 839.4 209.4 843.3 270.4 901.5 280.2 1000 301.2 1000 428.5L964.3 428.5C964.3 334.2 903.9 316.6 830.9 304.6L822.4 303.2C817.6 302.4 813.3 299.6 810.5 295.5 807.8 291.3 806.9 286.3 808.1 281.5 808 231.4 785.8 193.9 747 180.9 711.7 169.2 673 181.4 650.5 211.4 646.6 216.7 640.3 219.2 633.5 218.3 627.1 217.4 621.6 212.9 619.4 206.8 604.6 165.8 583.3 131.6 556 104.8 486 36 390.5 17.4 300.4 55 225.3 86 166.5 175.5 166.5 258.8L168.3 287.7C168.8 296.3 163.1 304 154.8 306.1 110.3 317.1 35.7 351.3 35.7 455.9 35.7 533.9 79.2 577.3 115.6 599.9 126.7 606.7 138 607.1 155.6 607.1L155.6 607.1ZM964.3 720L932.8 718.2C924.5 717.9 916.3 723.5 914.4 732.1 908.4 758.8 897.9 784.2 883.2 807.4 878.5 814.8 879.9 824.5 886.4 830.3L909.9 851.3 851.3 909.9 830.4 886.5C824.6 879.9 814.9 878.6 807.5 883.2 784.3 897.9 758.9 908.5 732.1 914.5 723.6 916.4 717.7 924.2 718.2 933L720 964.3 637.1 964.3 639 932.9C639.5 924.2 633.6 916.4 625.1 914.5 598.3 908.4 572.9 897.9 549.6 883.2 542.3 878.6 532.6 879.9 526.8 886.4L505.9 909.9 447.2 851.3 470.7 830.3C477.3 824.6 478.6 814.9 474 807.5 459.3 784.3 448.8 758.9 442.7 732.1 440.8 723.6 434 718 424.3 718.2L392.9 720 392.9 637.1 424.4 638.9C434.1 639.1 440.9 633.5 442.8 625 448.9 598.3 459.4 572.9 474.1 549.7 478.8 542.4 477.4 532.7 470.9 526.9L447.2 505.8 505.9 447.2 526.9 470.8C532.7 477.3 542.4 478.6 549.8 474 573 459.4 598.4 448.9 625.1 442.9 633.6 440.9 639.4 433.1 639 424.4L637.1 392.8 720 392.8 718.2 424.4C717.7 433.1 723.6 441 732.1 442.9 758.8 448.9 784.1 459.4 807.3 474.1 814.7 478.7 824.4 477.4 830.2 470.9L851.3 447.2 909.9 505.8 886.3 526.8C879.8 532.7 878.4 542.3 883.1 549.7 897.8 572.9 908.3 598.2 914.4 625 916.3 633.5 923.1 639.5 932.8 638.9L964.3 637.1 964.3 720ZM981.1 600.4L945.4 602.4C939.6 581.9 931.4 562.3 921.1 543.7L947.8 519.8C951.5 516.6 953.6 511.9 953.8 507 953.9 502.1 952 497.4 948.5 493.9L863.2 408.5C859.7 405.1 855.2 403.3 850 403.3 845.1 403.5 840.5 405.6 837.2 409.3L813.3 436.1C794.8 425.8 775.1 417.6 754.7 411.8L756.7 376C757 371 755.3 366.2 751.9 362.7 748.5 359.1 743.8 357.1 738.9 357.1L618.3 357.1C613.3 357.1 608.6 359.1 605.3 362.7 601.9 366.2 600.1 371 600.4 376L602.5 411.8C582 417.6 562.4 425.7 543.8 436L519.9 409.3C516.6 405.6 512 403.5 507.1 403.3 502.3 403.4 497.4 405.1 494 408.5L408.6 493.9C405.1 497.4 403.2 502.1 403.4 507 403.5 511.9 405.7 516.6 409.4 519.8L436.1 543.7C425.8 562.3 417.6 582 411.8 602.4L376 600.4C371.2 600.3 366.3 601.8 362.7 605.2 359.2 608.6 357.1 613.3 357.1 618.2L357.1 738.9C357.1 743.8 359.2 748.5 362.7 751.9 366.3 755.2 371.2 757 376 756.7L411.6 754.6C417.5 775.2 425.6 794.9 436 813.5L409.4 837.2C405.7 840.5 403.5 845.1 403.4 850.1 403.2 854.9 405.1 859.7 408.6 863.2L494 948.5C497.4 952 502.1 953.6 507.1 953.7 512 953.6 516.6 951.5 519.9 947.8L543.6 921.1C562.3 931.6 582 939.7 602.5 945.6L600.4 981.1C600.1 986 601.9 990.8 605.3 994.4 608.6 998 613.3 1000 618.3 1000L738.9 1000C743.8 1000 748.5 998 751.9 994.4 755.3 990.8 757 986 756.7 981.1L754.7 945.6C775.2 939.7 794.9 931.6 813.5 921.2L837.2 947.8C840.5 951.5 845.1 953.6 850 953.7 855.4 953.8 859.7 952 863.2 948.5L948.5 863.2C952 859.7 953.9 854.9 953.8 850.1 953.6 845.1 951.5 840.5 947.8 837.2L921.1 813.4C931.5 794.8 939.6 775.2 945.5 754.6L981.1 756.7C985.9 757 990.8 755.2 994.4 751.9 998 748.5 1000 743.8 1000 738.9L1000 618.2C1000 613.3 998 608.6 994.4 605.2 990.8 601.8 985.9 600.3 981.1 600.4L981.1 600.4Z" fill="#FFFFFF"/>
</g>
</g>
</defs>
</g>
<style data-styled="true" data-styled-version="5.3.11">.cqiPZP{cursor:pointer;}/*!sc*/
data-styled.g74[id="sc-cmaqmh"]{content:"cqiPZP,"}/*!sc*/
.eGruRC{stroke:#555;background-color:#555;stroke-width:1px;}/*!sc*/
data-styled.g75[id="sc-kAkpmW"]{content:"eGruRC,"}/*!sc*/
.fzbdhh{stroke-width:0;stroke:none;fill:#f2f3f3;}/*!sc*/
data-styled.g76[id="sc-gFVvzn"]{content:"fzbdhh,"}/*!sc*/
.hgiJwm{font-size:10px;line-height:12.5;stroke:none;}/*!sc*/
data-styled.g77[id="sc-brPLxw"]{content:"hgiJwm,"}/*!sc*/
.khZmcS{fill:var(--color-text-form-secondary-btuye6,#687078);}/*!sc*/
data-styled.g103[id="sc-eyvILC"]{content:"khZmcS,"}/*!sc*/
.kohnMw{font-weight:400;font-size:12px;line-height:16px;font-family:Amazon Ember,Arial,Roboto,Arial,sans-serif;text-shadow:none;fill:var(--color-text-button-primary-default-qh066v,#16191f);}/*!sc*/
data-styled.g104[id="sc-gfoqjT"]{content:"kohnMw,"}/*!sc*/
.cwOTqA{fill:#fff9cc;stroke:var(--color-text-form-secondary-btuye6,#687078);stroke-width:0.6px;}/*!sc*/
data-styled.g105[id="sc-kbousE"]{content:"cwOTqA,"}/*!sc*/
</style>
<style>
.new-look-state-node &gt; rect:first-of-type {
  stroke: #687078;
  stroke-width: 1px;
  fill: #FFFFFF;
}

.new-look-state-node .error-icon circle {
 stroke-linejoin: round;
}

.new-look-state-node .error-icon circle, .new-look-state-node .error-icon path {
 stroke: var(--color-border-status-error-si9bvu, #d13212);
 fill: none;
 stroke-width: 2px;
}

.new-look-state-node.has-errors &gt; rect:first-of-type {
 stroke: var(--color-border-status-error-si9bvu, #d13212);
 fill: var(--color-background-status-error-qqw3y6, #fdf3f1);
}

.new-look-state-node.has-errors &gt; .bounding-box &gt; .new-look-state-node-sub &gt; rect {
  stroke: var(--color-border-status-error-si9bvu, #d13212);
  fill: var(--color-background-status-error-qqw3y6, #fdf3f1);
}

.new-look-state-node .handle path {
  stroke: var(--color-border-dropdown-item-hover-t6obhh, #879596);
  stroke-width: 1px;
  fill: none;
}

.new-look-state-node {
  font-weight: 400;
  font-family: Amazon Ember, Arial, Roboto, Arial, sans-serif;
  text-shadow: none;
}

.new-look-state-node .line1 {
  fill: #687078;
  font-size: 12px;
}

.new-look-state-node .line2 {
  fill: #16191f;
}

.selected.node &gt; .new-look-state-node &gt; rect,
.selected.node &gt; .new-look-state-node &gt; .new-look-state-node &gt; rect,
.selected.node &gt; .new-look-state-node &gt; .bounding-box &gt; rect,
.selected.node &gt; .new-look-state-node.has-errors &gt; rect,
.selected.node &gt; .new-look-state-node.has-errors &gt; .bounding-box &gt; rect,
.selected.node &gt; .new-look-state-node.has-errors &gt; .new-look-state-node &gt; rect,
.selected.node &gt; .new-look-state-node &gt; .bounding-box &gt; .new-look-state-node-sub &gt; rect
 {
  stroke: var(--color-border-status-info-fjyzd6, #0073bb);
  fill: var(--color-background-status-info-60ssq8, #f1faff);
  stroke-width: 1px;
}

.new-look-state-node-sub .item-source.not-specified {
  height: 15px;
  color: #687078;
  font-family: "Amazon Ember";
  font-size: 12px;
  letter-spacing: 0;
  line-height: 16px;
  font-weight: 400;
}
.new-look-state-node-sub .item-source .item-source_name{
  font-weight: 600;
}
.new-look-state-node-sub .item-source.not-specified .item-source_name{
  font-weight: 400;
}

.new-look-state-node-sub .item-source.not-specified {
  font-style: italic;
}

.new-look-state-node-sub &gt; rect,
.new-look-state-node &gt; .bounding-box &gt; rect {
  stroke: var(--color-border-control-default-ie1oqq, #687078);
  fill: #ffffff;
}

.new-look-graph .drag-source {
  opacity: 0.2;
}

.new-look-graph .edge, .new-look-graph path.starting-connection {
  stroke-width: 1px;
  stroke: var(--color-text-form-secondary-btuye6, #687078);
  marker-end: url(#large-arrowhead);
}

.new-look-graph .edge-label {
  cursor: pointer;
}

.new-look-graph .edge-label rect {
  stroke-width: 1px;
  stroke: var(--color-border-control-default-ie1oqq, #687078);
  fill: #fafafa;
}

.new-look-graph .edge-label.selected rect {
  stroke: var(--color-border-status-info-fjyzd6, #0073bb);
  fill: var(--color-background-status-info-60ssq8, #f1faff);
  stroke-width: 0.6px;
}



.new-look-graph .edge-label .label {
  fill: var(--color-text-form-secondary-btuye6, #687078);
  font-family: Amazon Ember, Arial, Roboto, Arial, sans-serif;
}

/* centering the shape text */
@-moz-document url-prefix() {
  .new-look-graph .shape + text,
  .new-look-graph .edge-label text {
    transform: translateY(3.5px);
  }
}

.new-look-graph .edge path {
  marker-end: url(#large-arrowhead) !important;
}

.new-look-graph .edge.selected path{
  stroke: var(--color-border-status-info-fjyzd6, #0073bb);
  stroke-width: 1.1px;
}

.new-look-graph .edge.dragging-over path, .new-look-graph  g.dragging-over .starting-connection {
  stroke: #5C86FF;
  stroke-width: 2px;
}

.new-look-graph .edge.dragging-over path, .new-look-graph .dragging-over path.starting-connection {
  marker-end: url(#large-highlighted-arrowhead) !important;
}

.new-look-graph .edge.dragging-over .edge-label text {
  fill: #5C86FF;
}

#large-highlighted-arrowhead {
  fill: #5C86FF;
}

#large-highlighted-arrowhead path {
  stroke: none;
}

.new-look-graph .edge.drop-not-supported path, g.drop-not-supported .starting-connection {
  stroke: red;
}

.new-look-graph .edge.drop-not-supported .edge-label text {
  fill: red;
}

.new-look-graph .edge.drop-not-supported path {
  marker-end: url(#large-error-arrowhead) !important;
}

#large-error-arrowhead {
  fill: red;
}

.node-container * &gt; .icon  {
  &gt; rect {
    fill: #fafafa;
  }
  &gt; line {
    stroke: #d5dbdb;
  }
}


.node.Placeholder.dragging-over rect {
  stroke: var(--color-border-status-info-fjyzd6, #0073bb);
  fill: var(--color-background-status-info-60ssq8, #f1faff);
  stroke-width: 2px;
}

.node.Placeholder.dragging-over .label {
  fill: var(--color-text-status-info-f9d9f2, #0073bb);
}

g.Placeholder rect {
  stroke-dasharray: 5 4;
  stroke: var(--color-border-dropdown-item-hover-t6obhh, #879596);
  fill: #ffffff;
  stroke-width: 1px;
}

g.Placeholder .label {
  font-style: italic;
  fill: var(--color-text-input-placeholder-lhl4lu, #687078);
}

.node.Placeholder.drop-not-supported rect {
  stroke: red;
}

.node.Placeholder.drop-not-supported .label {
  fill: red;
}
</style>
<style>.line2 { font-size: 14px }</style>
</svg>g…]()


## Charts
Still under development.

## Requirements
To run this pipeline, the user needs:
1. A Shopee seller account;
2. A AWS account, root or IAM user, being IAM user recommended for safety reasons.

## Creating IAM roles
This section will show what IAM roles need to be created.

## Running the pipeline

### Configuring and running Terraform
To run the pipeline, first adjust the configurations for each main.tf file. Afterwards, for each of them, run:
```
terraform init
```
Then, please run this command:
```
terraform plan
```
Finally, execute and type "yes":
```
terraform apply
```

### Loading local files to S3
Under elaboration.

### Connect and transfer files to EC2
Inside your local machine user, in path that probably looks like "/home/username/.ssh" or "c:/users/username/.ssh", create a `config` file like this:

```
Host host-name
    HostName 1.234.56.789
    User ec2-user
    IdentityFile c:/users/username/.ssh/ec2-key.pem
```
> [!IMPORTANT]
> Make sure a .pem key value pair exists in AWS that can be used for the SSH connection.

Then, run the command:

```
ssh host-name
```

After connecting to the EC2 instance, transfer the project to EC2.

```
scp -i ~/.ssh/ec2-key.pem -r "c:/users/username/projects/e-commerce-sales-pipeline/cloud/" ec2-user@1.234.56.789:/home/ec2-user/projects
```

> [!TIP]
> If needed, the EC2 instance can be accessed through VSCode via the extension [Remote-SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)

### Running the rest of the pipeline

Inside the EC2 instance, install:
```
sudo yum install python3-pip -y
pip3 install dlt boto3 psycopg2-binary pandas pyarrow dbt-core dbt-redshift
```
> [!IMPORTANT]
> Make sure that the EC2 instance has IAM roles that include `AmazonS3ReadOnlyAccess` and `AmazonSSMManagedInstanceCore`

Then, preferably inside the path to the loading scripts, run:
```
python3 shopee.py
```

After loading, access Redshift and create the following spectrum schemas and tables:

```
CREATE EXTERNAL SCHEMA spectrum_schema
FROM DATA CATALOG
DATABASE 'spectrum_db'
IAM_ROLE 'arn:aws:iam::xxxxxxxxxxxx:role/your-IAM'
CREATE EXTERNAL DATABASE IF NOT EXISTS;

CREATE EXTERNAL TABLE spectrum_schema.kit_components (
  main_sku VARCHAR(15),
  product VARCHAR(50),
  sku VARCHAR(15),
  component_sku VARCHAR(15),
  component_name VARCHAR(75) )
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3://e-commerce-sales-bucket/data/test-spectrum/kit_components/'
TABLE PROPERTIES ('skip.header.line.count'='1');

CREATE EXTERNAL TABLE spectrum_schema.product_sku_cost (
  main_sku VARCHAR(15),
  product VARCHAR(50),
  sku VARCHAR(15),
  component_name VARCHAR(50),
  begin_date TIMESTAMP,
  end_date TIMESTAMP,
  cost NUMERIC(7, 2) )
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 's3://e-commerce-sales-bucket/data/test-spectrum/product_sku_cost/'
TABLE PROPERTIES ('skip.header.line.count'='1');
```

Then, under `/home/ec2-user/projects/dbt_files/e_commerce_sales/` run:
```
dbt deps
```

Follow it by:
```
dbt run --profiles-dir "/home/ec2-user/projects/dbt_files/e_commerce_sales" --target dev
```

### Under development
Orchestration;
Applying AWS Glue to the shopee files to avoid duplications;
Creating python scripts for external tables.

## Contact
If you have any questions or want to reach me out, you can contact me on the following channels:
- LinkedIn: www.linkedin.com/in/nicolas-imagawa
- GitHub: https://github.com/NicolasImagawa


