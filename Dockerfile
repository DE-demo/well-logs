FROM public.ecr.aws/lambda/python:3.12

COPY wells/ /tmp/package/wells
COPY pyproject.toml README.md /tmp/package
RUN pip install /tmp/package/
COPY lambda_function.py ${LAMBDA_TASK_ROOT}

CMD ["lambda_function.lambda_handler"]
