# Generated by Django 2.2.7 on 2019-11-18 09:48

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('smalldata', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='TrainingUtterance',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('category', models.CharField(max_length=500)),
                ('text', models.CharField(max_length=500)),
            ],
        ),
    ]
